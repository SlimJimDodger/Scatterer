// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Similar to regular FX/Glass/Stained BumpDistort shader
// from standard Effects package, just without grab pass,
// and samples a texture with a different name.

Shader "Scatterer/ParticleRefraction" {
Category {

	// We must be transparent, so other objects are drawn before this one.
	Tags { "Queue"="Transparent" "RenderType"="Transparent" }

	SubShader {

		Pass {
			//Name "BASE"
			//Tags { "LightMode" = "Always" }

			Blend SrcAlpha OneMinusSrcAlpha
									
CGPROGRAM


#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fog
#include "UnityCG.cginc"

struct appdata_t {
	float4 vertex : POSITION;
	float2 texcoord: TEXCOORD0;
};

struct v2f {
	float4 pos    : SV_POSITION;
	float4 uvgrab : TEXCOORD0;
	float2 uv	  : TEXCOORD1;
	float4 screenPos: TEXCOORD2;
	float2 uvNew :  TEXCOORD3;
	float  distToCameraPlane: TEXCOORD4;
};

v2f vert (appdata_t v)
{
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	#if UNITY_UV_STARTS_AT_TOP
	float scale = -1.0;
	#else
	float scale = 1.0;
	#endif
	o.uvgrab.xy = (float2(o.pos.x, o.pos.y*scale) + o.pos.w) * 0.5;
	o.uvgrab.zw = o.pos.zw;
//	o.uvbump = TRANSFORM_TEX( v.texcoord, _BumpMap );
//	o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
	//o.uv=v.texcoord.xy;
	o.uv=v.texcoord.xy;
	o.screenPos = ComputeScreenPos(o.pos);
	o.uvNew = o.screenPos.xy / o.screenPos.w;
	//float4 clipSpaceOrigin = UnityObjectToClipPos(float4(0.0,0.0,0.0,1.0));
	//float4 screenSpaceOrigin = ComputeScreenPos(clipSpaceOrigin);
	//o.quadOrigin = v.vertex.xyz/v.vertex.w;

	//UNITY_TRANSFER_FOG(o,o.vertex);

	float3 viewSpacePos = UnityObjectToViewPos(v.vertex);
	o.distToCameraPlane = abs(viewSpacePos.z);

	return o;
}

sampler2D _refractionTexture;
sampler2D _heatTexture;

half4 frag (v2f i) : SV_Target
{
	float smooth = sin(i.uv.r*3.14)*sin(i.uv.g*3.14);
	//i.uv = frac(UNITY_PROJ_COORD(i.uvgrab).xy*2); //issue with this is that it becomes bigger or smaller when you approach, ie size is not constant in screen space
													//all I want is size to be constant in screen space regardless of moving right?
	//return float4(i.uvNew,0.0,1.0);
	//return float4(i.quadOrigin,1.0);
	//i.uv = frac(i.uvNew*4);
	//return float4(frac(i.uv),0.0,1.0);
//	float4 projCoord = UNITY_PROJ_COORD(i.uvgrab);
//	i.uv = frac(projCoord.xy*4);

	//i.uv = frac(5 * i.uv / max(i.distToCameraPlane,0.1));
	//return float4(i.distToCameraPlane*0.01,0.0,0.0,1.0);
	float2 distort = tex2D(_heatTexture,i.uv).rg;
	//float2 distort = tex2D(_heatTexture,frac(i.uv)).rg;
	//return float4(frac(5*i.uv / max(i.distToCameraPlane,0.1)),0.0,1.0);
	//return float4(distort,0.0,1.0);

//	i.uvgrab.xy = i.uvgrab.xy + 0.03*distort*smooth;
//	half4 col = tex2Dproj (_refractionTexture, UNITY_PROJ_COORD(i.uvgrab));

	//half4 col = tex2D (_refractionTexture, i.uvNew + 0.03*distort*smooth);
	//half4 col = tex2D (_refractionTexture, i.uvNew + 0.03*distort*smooth);
	//half4 col = tex2D (_refractionTexture, i.uvNew + clamp(i.distToCameraPlane*0.05,0.75,4.0) * 0.03*distort*smooth);
	//half4 col = tex2D (_refractionTexture, i.uvNew + clamp(i.distToCameraPlane*0.05,0.2,1.0) * 0.03*distort*smooth);
	//half4 col = tex2D (_refractionTexture, i.uvNew + clamp(10.0/i.distToCameraPlane,0.2,1.0) * 0.03*distort*smooth);
	half4 col = tex2D (_refractionTexture, i.uvNew + 0.015*distort*smooth);

	//half4 col = tex2D (_refractionTexture, i.uvNew) * 0.7;

	//return float4(col.rgb*0.97, smooth);
	return float4(col.rgb, 0.98);
}
ENDCG
		}
	}

}

}
