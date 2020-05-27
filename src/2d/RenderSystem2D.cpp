#include "RenderSystem2D.hpp"
#include "gfx/Viewport.hpp"
#include "Sprite.hpp"
#include "Canvas.hpp"
#include "FrameData2D.hpp"
#include "Camera2D.hpp"
#include "en/World.hpp"
#include "en/ComponentManager.hpp"

namespace ari::en
{
	ARI_COMPONENT_IMP(Node2D)
	ARI_COMPONENT_IMP(CanvasNode)


	RenderSystem2D::RenderSystem2D() :
		m_pFrameDataCurrent(nullptr),
		m_pFrameDataNext(nullptr)
	{
		TargetWindow.Handle = 0;
		TargetWindow.Index = 0;
	}
	RenderSystem2D::~RenderSystem2D()
	{
		if (TargetWindow.Index == 0)
		{
			gfx::RenderToWindow(TargetWindow);
			Sprite::Shutdown();
		}
	}
	void RenderSystem2D::Update(World* _world, const float& _elasoed, UpdateState::Enum _state)
	{
		gfx::RenderToWindow(TargetWindow);
		gfx::BeginDefaultPass(TargetWindow);

		m_pFrameDataCurrent = m_pFrameDataNext;
		if (m_pFrameDataCurrent)
		{
			//set the camera2D
			if (m_pFrameDataCurrent->Camera2dObj)
			{
				gfx::Viewport* pViewport = m_pFrameDataCurrent->Camera2dObj->GetViewport();
				gfx::SetViewProjMatrix(m_pFrameDataCurrent->Camera2dObj->_view,
					m_pFrameDataCurrent->Camera2dObj->_proj);

				m_pFrameDataCurrent->Camera2dObj->SetViewportRect(true);
				//m_pFrameDataCurrent->Camera2dObj->SetViewportRect(0,0,1333,700,true);

				for (auto node : m_pFrameDataCurrent->Nodes)
				{
					node->Render(m_pFrameDataCurrent->FrameDataTurnIndex);
				}

			}
		}
		gfx::EndPass();
		gfx::Commit();
		gfx::Present(TargetWindow);

	} // Update

	void RenderSystem2D::Configure(World* p_world)
	{
		p_world->Subscribe<events::OnComponentAssigned<Sprite>>(this);
		p_world->Subscribe<events::OnFrameData2D>(this);

	} // Configure

	void RenderSystem2D::Unconfigure(World* p_world)
	{
		p_world->unsubscribeAll(this);

	} // Unconfigure
	
	bool RenderSystem2D::NeedUpdateOn(UpdateState::Enum state)
	{
		return state == UpdateState::MainThreadState;
	}

	void RenderSystem2D::Receive(World* world, const events::OnComponentAssigned<Sprite>& event)
	{
		sx_unused(world);
		sx_unused(event);
		Sprite::Init(this);
	}

	void RenderSystem2D::Receive(World* world, const events::OnFrameData2D & event)
	{
		sx_unused(world);
		m_pFrameDataNext = event.frame_data_2d;
	}

} // ari::en