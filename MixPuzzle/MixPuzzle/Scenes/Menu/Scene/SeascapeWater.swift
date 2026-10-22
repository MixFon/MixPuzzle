//
//  SeascapeWater.swift
//  MixPuzzle
//
//  Вода для сцены меню: порт шейдера "Seascape" в SceneKit shader modifiers.
//
//  Оригинал: "Seascape" by Alexander Alekseev aka TDM - 2014
//  https://www.shadertoy.com/view/Ms2SD1
//  License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//  Contact: tdmaav@gmail.com
//
//  Этот файл — производная работа и распространяется под той же лицензией CC BY-NC-SA 3.0.
//
//  Что изменено относительно оригинала:
//  - убрана трассировка лучей (heightMapTracing) и своя камера: поверхность воды — настоящая
//    геометрия сцены, а глаз и направление взгляда берутся из камеры SceneKit;
//  - волны (map, 3 октавы) поднимают вершины плоскости в shader modifier `.geometry`;
//  - нормаль (map_detailed, 5 октав) и цвет воды (getSeaColor) считаются в `.fragment`;
//  - направление солнца, масштаб волн и резкость блика вынесены в настройки.
//

import SceneKit

enum SeascapeWater {

	struct Configuration {
		/// Сколько единиц Seascape приходится на одну единицу сцены. Больше — волны мельче
		var scale: Float = 2.0
		/// Размер плоскости воды в единицах сцены
		var size: CGFloat = 200
		/// Количество сегментов плоскости по каждой стороне. Нужны для волн в вершинном шейдере
		var segments: Int = 256
		/// Направление на солнце (как в оригинале)
		var sunDirection: SIMD3<Float> = SIMD3(0.0, 1.0, 0.8)
		/// Множитель резкости солнечного блика. В оригинале блик тем шире, чем дальше камера (600 / dist),
		/// а камера меню висит высоко, и без множителя блик расползается в белые пятна
		var specularSharpness: Float = 2.0
		/// Сила солнечного блика. В оригинале 1. С камерой сверху блики упираются в белый, поэтому их приглушаем
		var specularIntensity: Float = 0.25
	}

	/// Заменяет геометрию узла на плоскость с водой. Узел должен стоять в начале координат
	static func configure(node: SCNNode, configuration: Configuration = Configuration()) {
		let plane = SCNPlane(width: configuration.size, height: configuration.size)
		plane.widthSegmentCount = configuration.segments
		plane.heightSegmentCount = configuration.segments

		let material = SCNMaterial()
		// Цвет полностью считает шейдер, освещение сцены для воды не нужно
		material.lightingModel = .constant
		material.isDoubleSided = true
		material.shaderModifiers = [
			.geometry: geometryModifier(configuration: configuration),
			.fragment: fragmentModifier(configuration: configuration),
		]
		plane.materials = [material]

		node.geometry = plane
		// SCNPlane лежит в плоскости XY, поворачиваем его горизонтально.
		// После поворота: мировая X = локальная X, мировая Z = -локальная Y, высота = локальная Z
		node.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
	}

	// MARK: - Shader modifiers

	/// Общие функции волн. SceneKit собирает модификаторы в один исходник,
	/// поэтому у каждого модификатора свой префикс имён, чтобы не было повторных объявлений
	private static func seaFunctions(prefix: String) -> String {
		"""
		float \(prefix)hash(float2 p) {
			float h = dot(p, float2(127.1, 311.7));
			return fract(sin(h) * 43758.5453123);
		}

		float \(prefix)noise(float2 p) {
			float2 i = floor(p);
			float2 f = fract(p);
			float2 u = f * f * (3.0 - 2.0 * f);
			return -1.0 + 2.0 * mix(mix(\(prefix)hash(i + float2(0.0, 0.0)), \(prefix)hash(i + float2(1.0, 0.0)), u.x),
			                        mix(\(prefix)hash(i + float2(0.0, 1.0)), \(prefix)hash(i + float2(1.0, 1.0)), u.x), u.y);
		}

		float \(prefix)octave(float2 uv, float choppy) {
			uv += \(prefix)noise(uv);
			float2 wv = 1.0 - abs(sin(uv));
			float2 swv = abs(cos(uv));
			wv = mix(wv, swv, wv);
			return pow(1.0 - pow(wv.x * wv.y, 0.65), choppy);
		}

		// Высота волны в точке p (координаты xz в единицах Seascape). Аналог map / map_detailed
		float \(prefix)height(float2 p, float time, int iterations) {
			float freq = 0.16;   // SEA_FREQ
			float amp = 0.6;     // SEA_HEIGHT
			float choppy = 4.0;  // SEA_CHOPPY
			float2 uv = p;
			uv.x *= 0.75;
			const float2x2 octave_m = float2x2(float2(1.6, 1.2), float2(-1.2, 1.6));
			float h = 0.0;
			for (int i = 0; i < iterations; i++) {
				float d = \(prefix)octave((uv + time) * freq, choppy);
				d += \(prefix)octave((uv - time) * freq, choppy);
				h += d * amp;
				uv = uv * octave_m;
				freq *= 1.9;
				amp *= 0.22;
				choppy = mix(choppy, 1.0, 0.2);
			}
			return h;
		}

		"""
	}

	private static func geometryModifier(configuration: Configuration) -> String {
		let scale = format(configuration.scale)
		return seaFunctions(prefix: "seaGeo_") + """
		#pragma body

		float seaTime = 1.0 + scn_frame.time * 0.8; // SEA_TIME
		// Мировые xz точки плоскости (см. поворот узла) в единицах Seascape
		float2 seaXZ = float2(_geometry.position.x, -_geometry.position.y) * \(scale);
		float seaH = seaGeo_height(seaXZ, seaTime, 3); // ITER_GEOMETRY
		_geometry.position.z += seaH / \(scale);
		"""
	}

	private static func fragmentModifier(configuration: Configuration) -> String {
		let scale = format(configuration.scale)
		let sun = configuration.sunDirection
		return seaFunctions(prefix: "seaFrag_") + """
		float3 seaFrag_sky(float3 e) {
			e.y = (max(e.y, 0.0) * 0.8 + 0.2) * 0.8;
			return float3(pow(1.0 - e.y, 2.0), 1.0 - e.y, 0.6 + (1.0 - e.y) * 0.4) * 1.1;
		}

		float seaFrag_diffuse(float3 n, float3 l, float p) {
			return pow(dot(n, l) * 0.4 + 0.6, p);
		}

		float seaFrag_specular(float3 n, float3 l, float3 e, float s) {
			float nrm = (s + 8.0) / (3.141592 * 8.0);
			return pow(max(dot(reflect(e, n), l), 0.0), s) * nrm;
		}

		float3 seaFrag_color(float3 p, float3 n, float3 l, float3 eye, float3 dist, float sharpness, float intensity) {
			const float3 SEA_BASE = float3(0.0, 0.09, 0.18);
			const float3 SEA_WATER_COLOR = float3(0.8, 0.9, 0.6) * 0.6;
			const float SEA_HEIGHT = 0.6;

			float fresnel = clamp(1.0 - dot(n, -eye), 0.0, 1.0);
			fresnel = min(fresnel * fresnel * fresnel, 0.5);

			float3 reflected = seaFrag_sky(reflect(eye, n));
			float3 refracted = SEA_BASE + seaFrag_diffuse(n, l, 80.0) * SEA_WATER_COLOR * 0.12;

			float3 color = mix(refracted, reflected, fresnel);

			float atten = max(1.0 - dot(dist, dist) * 0.001, 0.0);
			color += SEA_WATER_COLOR * (p.y - SEA_HEIGHT) * 0.18 * atten;

			color += seaFrag_specular(n, l, eye, 600.0 * sharpness * rsqrt(dot(dist, dist))) * intensity;

			return color;
		}

		#pragma body

		float seaTime = 1.0 + scn_frame.time * 0.8; // SEA_TIME
		// Точка поверхности и глаз в мировых координатах, затем в единицах Seascape
		float3 seaWorld = (scn_frame.inverseViewTransform * float4(_surface.position, 1.0)).xyz;
		float3 seaEye = (scn_frame.inverseViewTransform * float4(0.0, 0.0, 0.0, 1.0)).xyz;
		float3 seaP = seaWorld * \(scale);
		float3 seaDist = seaP - seaEye * \(scale);
		float3 seaDir = normalize(seaDist);

		// Нормаль по конечным разностям (getNormal). EPSILON_NRM = 0.1 / iResolution.x, ширина экрана ~1000
		float seaEps = max(dot(seaDist, seaDist) * 0.0001, 0.001);
		float seaH = seaFrag_height(seaP.xz, seaTime, 5); // ITER_FRAGMENT
		float3 seaN = normalize(float3(
			seaH - seaFrag_height(float2(seaP.x + seaEps, seaP.z), seaTime, 5),
			seaEps,
			seaH - seaFrag_height(float2(seaP.x, seaP.z + seaEps), seaTime, 5)
		));
		seaP.y = seaH;

		float3 seaLight = normalize(float3(\(format(sun.x)), \(format(sun.y)), \(format(sun.z))));
		float3 seaColor = seaFrag_color(seaP, seaN, seaLight, seaDir, seaDist, \(format(configuration.specularSharpness)), \(format(configuration.specularIntensity)));

		// В оригинале итог pow(color, 0.65) выводится на экран как есть.
		// SceneKit сам переводит линейный цвет в sRGB (~pow 1/2.2), поэтому компенсируем
		seaColor = pow(max(seaColor, float3(0.0)), float3(0.65 * 2.2));
		_output.color = float4(seaColor, 1.0);
		"""
	}

	/// Число для вставки в код шейдера: всегда с точкой, чтобы Metal видел float
	private static func format(_ value: Float) -> String {
		String(format: "%.4f", locale: Locale(identifier: "en_US_POSIX"), value)
	}
}
