#include "gfx/gfx.hpp"
#include "gfx/Application.hpp"
#include "en/World.hpp"
#include "3d/RenderSystem.hpp"
#include "3d/SceneSystem.hpp"
#include "3d/Camera.hpp"
#include "3d/BoxShape.hpp"

class _3dApp : public ari::Application
{
public:

	~_3dApp() = default;

	ari::gfx::GfxSetup* GetGfxSetup() override
	{
		return &m_setup;
	}

	void OnInit() override
	{
		// Add systems
		m_world.AddSystem(&m_renderer);
		m_world.AddSystem(&m_scene_mgr);

		// Create entity and add box and camera
		ari::en::EntityHandle entity = m_world.CreateEntity();
		auto camera = m_world.CreateComponent<ari::en::Camera, ari::en::Node3D>();
		camera.Component->Position.x = 3.f;
		camera.Component->Position.y = 3.f;
		camera.Component->Position.z = 3.f;
		camera.Component->Target.z = 0.0f;
		m_world.AddDerivedComponent<ari::en::Camera, ari::en::Node3D>(entity, camera);
		auto box = m_world.CreateComponent<ari::en::BoxShape, ari::en::Node3D>();
		m_world.AddDerivedComponent<ari::en::BoxShape, ari::en::Node3D>(entity, box);
	}

	void OnFrame(float _elapsedTime) override
	{
		m_world.Update(_elapsedTime);
	}

	void OnCleanup() override
	{
		
	}

	void OnEvent(ari_event* event, ari::io::WindowHandle _window) override
	{

	}

private:

	ari::gfx::GfxSetup			m_setup;
	ari::en::World				m_world;
	ari::en::RenderSystem		m_renderer;
	ari::en::SceneSystem		m_scene_mgr;
};

ARI_MAIN(_3dApp)
