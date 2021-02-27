using System;
using System.Collections;
using Atma;

namespace ari.en
{
	[Serializable]
	class AtlasSpriteData
	{
		public String name = null ~ delete _;

		public List<int> size = null ~ delete _;

		public List<int> sprite_rect = null ~ delete _;

		public List<int> sheet_rect = null ~ delete _;

	}
}
