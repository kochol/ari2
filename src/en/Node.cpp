#include "Node.hpp"

namespace ari
{
	namespace en
	{
		void Node::AddChild(Node * _child)
		{
			if (!m_mChilds.Contains(_child->GetId()))
				m_mChilds.Add(_child->GetId(), core::Array<Node*>());

			m_mChilds[_child->GetId()].Add(_child);
		}

		void Node::RemoveChild(Node * _child)
		{
			auto& v = m_mChilds[_child->GetId()];
			v.EraseSwap(v.FindIndexLinear(_child, 0, v.Size() - 1));
		}

		bool Node::HasChildWithId(uint32_t _id) const
		{
			return m_mChilds.Contains(_id);
		}

		const core::Array<Node*>& Node::GetChildren(uint32_t _id)
		{
			return m_mChilds[_id];
		}

	} // en
	
} // ari
