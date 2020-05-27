#pragma once

#include "Node2D.hpp"
#include "gfx/Viewport.hpp"
#include "sx/math.h"

namespace ari::en
{

	class Camera2D : public Node2D
	{
	public:
		ARI_COMPONENT_CHILD(Camera2D, Node2D)

		//! Constructor
		Camera2D()
		{
		}

		//! Destructor
		virtual ~Camera2D() = default;

		float		width,
					height;
		sx_mat4		_view,
					_proj;
		bool		_isActive = false;

		//! Rotate the Camera around Z axis
		void Rotate(float _angle);


		//! Move Camera left & right
		void MoveLR(const float& _speed);

		//! Move Camera up & down
		void MoveUD(const float& _speed);

		gfx::Viewport* GetViewport();

		void SetViewport(const gfx::Viewport& _viewport);

		void SetViewportRect(int x, int y, int width, int height, bool top_left);
		//! set current window size to viewport rect size 
		void SetViewportRect(bool top_left);

		void SetScissorRect(int x, int y, int width, int height, bool top_left);

	protected:

		
		gfx::Viewport	m_viewport;
		bool			m_bHasViewPort = false;

	}; // Camera2D

} // ari::en
