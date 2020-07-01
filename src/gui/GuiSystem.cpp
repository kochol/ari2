#include "en/World.hpp"
#include "GuiSystem.hpp"
#include "sokol_gfx.h"
#include "cimgui/imgui/imgui.h"

#ifdef ARI_GLFW
#define SOKOL_IMPL
#define SOKOL_NO_ENTRY
#endif

#include "sokol_app.h"

#define SOKOL_IMGUI_IMPL
#include "util/sokol_imgui.h"
#include "io/Window.hpp"
#include "en/ComponentManager.hpp"
#include "Gui.hpp"

namespace ari
{
	namespace gui
	{
		ARI_COMPONENT_IMP(Gui)

		GuiSystem::GuiSystem()
		{
			core::MemoryPool<Gui>::Setup(65536);
		}

		GuiSystem::~GuiSystem()
		{
		}

		void GuiSystem::Configure(World* p_world)
		{
			simgui_desc_t desc;
			core::Memory::Fill(&desc, sizeof(simgui_desc_t), 0);
			simgui_setup(&desc);
			p_world->Subscribe<events::OnInputEvent>(this);
		}

		void GuiSystem::Unconfigure(World* p_world)
		{
			simgui_shutdown();
			p_world->unsubscribeAll(this);
		}

		void GuiSystem::Receive(World* p_world, const events::OnInputEvent& event)
		{
			simgui_handle_event(reinterpret_cast<sapp_event*>(event.event));
		}

		void GuiSystem::Update(World* _world, const float& _elapsed,
			UpdateState::Enum _state)
		{
			core::RectI size = io::GetWindowSize({ 0,0 });
			simgui_new_frame(size.width, size.height, _elapsed);

			_world->GetDerivedComponents<Gui>([this](const ComponentHandle<Gui>& gui)
				{
					this->RenderGui(gui.Component);
				});

			simgui_render();
		}

		bool GuiSystem::NeedUpdateOn(UpdateState::Enum _state)
		{
			return _state == UpdateState::MainThreadState;
		}

		void GuiSystem::RenderGui(Entity* entity) const
		{
			entity->GetComponents<Gui>([this](const ComponentHandle<Gui>& n)
				{
					RenderGui(n.Component);
				});
			if (entity->HasChildWithId(Entity::Id))
			{
				auto l = entity->GetChildren(Entity::Id);
				for (auto e : l)
				{
					RenderGui(reinterpret_cast<Entity*>(e));
				}
			}
		}

		void GuiSystem::RenderGui(Gui * _gui) const
		{
			if (!_gui->Visible)
				return;

			if (_gui->SameLine)
				ImGui::SameLine();

			if (_gui->Separator)
				ImGui::Separator();

			if (_gui->BeginRender())
			{
				_gui->GetChildren([this](Node* n)
					{
						if (n->GetBaseId() == Gui::Id)
						{
							this->RenderGui(reinterpret_cast<Gui*>(n));
						}
						else if (n->GetId() == Entity::Id)
						{
							this->RenderGui(reinterpret_cast<Entity*>(n));
						}
					});
			}
			_gui->EndRender();
		}

	} // gui
	
} // ari
