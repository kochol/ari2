#pragma once
#include "Node2D.hpp"
#include "gfx/gfx.hpp"

namespace ari::en
{
	class RenderSystem2D;

	class Sprite : public Node2D
	{
	public:

		ARI_COMPONENT_CHILD(Sprite, Node2D)

		//! Constructor
		Sprite();

		//! Destructor
		virtual ~Sprite() = default;

		//! Render
		void Render(const int& _frameTurnIndex) override;

		gfx::TextureHandle Texture;
		sx_vec4 v4Color;

		static void Init(RenderSystem2D* render_system_2D);
		static void Shutdown();

		void SetColor(float r, float g, float b, float a);

		static gfx::BufferHandle m_sVBPos;
		static gfx::BufferHandle m_sIB;
		static gfx::PipelineHandle m_sPipeline;
		static gfx::BindingHandle m_sBinding;



	};

} // ari::en


#include "Meta.h"

namespace meta
{
	template <>
	inline auto registerMembers<ari::en::Sprite>()
	{
		return std::tuple_cat(
			meta::getMembers<ari::en::Node2D>()
		);
	}
}
