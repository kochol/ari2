#pragma once

#include "en/Node.hpp"

namespace ari::en
{
	namespace sfx
	{
		class Sfx : public Node
		{
		public:
			ARI_COMPONENT(Sfx)

			virtual ~Sfx() = default;
		};
	} // namespace sfx

} // namespace ari