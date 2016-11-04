Shader "Custom/LightingModel_02" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_RampTex ("Ramp", 2D) = "white" {}
		_MainTex ("Main", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "white" {}
	}
	SubShader {
		Tags{
			"Rendertype" = "Opaque"
		}

		CGPROGRAM
		//We make sure the shader is going to search for a "ToonLighting"-Model,
		//As there is no other "Toon" known to Unity we can use it.
		//We can't use names such as Lambert, because Unity already knows a model with that name
		#pragma surface surf Toon

		sampler2D _MainTex;
		sampler2D _RampTex;
		sampler2D _NormalMap;
	    fixed4 _Color;

	    //The name is important in this funtion, the first part of the name will always be lighting
	    //This is so Unity understands that this is a new, custom lighting model
	    //The second part of the name in my case "Toon", is the name you decided in the #pragma

	    //Besides the name we want some parameters in this function
	    //We give SurfaceOutput the name "s"
	    //We ask unity to send us the lighting direction with "fixed3 lightDir", xyz directions
	    //The last thing we want from Unity is the attenuation, in other words the intensity of the light
		half4 LightingToon (SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
			//We make a variable named NdotL (Normal - dot - Lightdir), and get the dot-product of the 2 vectors
			//This so we can make a single vector of it (if i'm correct)
			half NdotL = dot(s.Normal, lightDir);

			//Here we give the NdotL our ramptexture, this texture is important for the overall look
			//The best thing you can do is use a ramptexture wit hard cutoffs (if you want ofcourse)
			//This makes the effect really clear
			NdotL = tex2D(_RampTex, fixed2(NdotL, 0.5));

			//In this part we make a variable "c" that is going to return the rgba values 
			fixed4 c;
			//The c.rgb value based on the dot-product we calculated above, and the attenuation
			c.rgb = s.Albedo * _LightColor0.rgb * NdotL * atten;
			c.a = s.Alpha;
			return c;
		}

		//Other shader stuff from here

		struct Input {
			float2 uv_MainTex;
			float2 uv_NormalMap;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
		}
		ENDCG
	}
	FallBack "Diffuse"
}