using System;
using System.Collections;
using Atma;

namespace ari.en
{
	[Serializable]
	class AtlasData
	{
		public String image = null ~ delete _;

		public float image_width;

		public float image_height;

		public List<AtlasSpriteData> sprites = null ~ DeleteContainerAndItems!(_);
	}
}
