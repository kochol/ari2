using System;
using ari.io;
using Atma;

namespace ari.en
{
	delegate void dOnAtlasCreated(Atlas _atlas);

	class Atlas
	{
		AtlasData data = null ~ delete _;
		TextureHandle texture;
		public TextureHandle Texture {
			get
			{
				return texture;
			}
		}

		public static void CreateAtlas(char8* _path, dOnAtlasCreated _onAtlas)
		{
			Io.LoadFile(_path, new (_data, size) =>
				{
					// deserialize atlas
					let s = scope String((char8*)_data, size);
					let atlas_data = new AtlasData();
					JsonConvert.Deserialize<AtlasData>(atlas_data, s);
					let a = new Atlas();
					a.data = atlas_data;

					// Load atlas texture
					s.Clear();
					s.Append(_path);
					if (s.LastIndexOf('/') > 0)
					{
						s.RemoveToEnd(s.LastIndexOf('/') + 1);
					}
					else if (s.LastIndexOf('\\') > 0)
					{
						s.RemoveToEnd(s.LastIndexOf('\\') + 1);
					}
					else
					{
						s.RemoveToEnd(s.LastIndexOf(':') + 1);
					}
					s.Append(atlas_data.image);
					a.texture = Gfx.LoadTexture(s);
					_onAtlas(a);
					delete _onAtlas;
				}, null);
		}

		public Vector4 GetSpriteUV(String _name)
		{
			AtlasSpriteData s = null;
			for (var d in data.sprites)
			{
				if (d.name == _name)
				{
					s = d;
					break;
				}	
			}
			if (s == null)
			{
				let err = scope String();
				err.AppendF("Can't find sprite {} in atlas {}", _name, data.image);
				Logger.Error(err);
				return .();
			}
			float u0 = s.sheet_rect[0] / data.image_width;
			float u1 = s.size[0] / data.image_width;
			float v0 = s.sheet_rect[1] / data.image_height;
			float v1 = s.size[1] / data.image_height;
			return .(u0, v0, u1, v1);
		}

	}
}
