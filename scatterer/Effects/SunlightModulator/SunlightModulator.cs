using UnityEngine;
using System.Collections;
using System.IO;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;

using KSP.IO;

namespace scatterer
{
	public class SunlightModulator : MonoBehaviour
	{
		Color originalColor;
		Color modulateColor;
		Light sunLight;
		bool applyModulation = false;
		SunlightModulatorPreRenderHook  preRenderHook;
		SunlightModulatorPostRenderHook postRenderHook;
		
		private SunlightModulator()
		{																																						  //but also the issue is that internalCamera
		}

		void Awake()
		{
			if (sunLight == null && Core.Instance.sunLight != null)
			{
				sunLight = Core.Instance.sunLight.GetComponent<Light>();
				preRenderHook = (SunlightModulatorPreRenderHook)Core.Instance.farCamera.gameObject.AddComponent(typeof(SunlightModulatorPreRenderHook));
				postRenderHook = (SunlightModulatorPostRenderHook)Core.Instance.nearCamera.gameObject.AddComponent(typeof(SunlightModulatorPostRenderHook)); //less than optimal, doesn't affect internalCamera
			}
		}

		public void OnPreCull() //added to scaledSpaceCamera, called before any calls from skyNode or oceanNode
		{
			storeOriginalColor ();
		}

		public void storeOriginalColor()    //may not be necessary every frame?
		{
			if (sunLight != null)
			{
				originalColor = sunLight.color;
				//Debug.Log ("store original color " + originalColor.ToString ());
			}
		}

		public void modulateByAttenuation(float inAttenuation) //called by skynode, ie scaledSpaceCamera onPreCull
		{
			modulateColor *= inAttenuation;
			applyModulation = true;
		}

		public void modulateByColor(Color inColor)
		{
			modulateColor *= inColor;
			applyModulation = true;
		}

		public void applyColorModulation()  //called by hook on farCamera onPreRender
		{
			if (applyModulation)
			{
				sunLight.color = modulateColor * originalColor;
				modulateColor = Color.white;
				if (Core.Instance.integrateWithEVEClouds)	//preserve original directional light color to not have double extinction
					Shader.SetGlobalColor("scattererOrigDirectionalColor",originalColor);
			}
		}
		
		public void restoreOriginalColor()  //called by hook on nearCamera/IVAcamera onPostRender  //may not be necessary every frame?
		{
			if (applyModulation)
			{
				sunLight.color = originalColor;
				applyModulation = false;
			}
		}

		public void OnDestroy()
		{
			Component.Destroy (preRenderHook);
			Component.Destroy (postRenderHook);
		}
	}
}

