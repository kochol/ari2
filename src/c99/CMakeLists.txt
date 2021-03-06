fips_begin_module(cari_2d)
    add_definitions(-DARI_NO_MAIN=1 -DCARI_NO_EXPORT=1)
    set(CMAKE_CXX_STANDARD 17)
    fips_vs_warning_level(3)
    fips_deps(ari_2d)
    fips_files(
        2d.h                    2d.cpp
        macros.h
    )
fips_end_module()

fips_begin_module(cari_3d)
    add_definitions(-DARI_NO_MAIN=1 -DCARI_NO_EXPORT=1)
    set(CMAKE_CXX_STANDARD 17)
    fips_vs_warning_level(3)
    fips_deps(ari_3d)
    fips_files(
        3d.h                    3d.cpp
        macros.h
    )
fips_end_module()

fips_begin_module(cari_core)
    add_definitions(-DARI_NO_MAIN=1 -DCARI_NO_EXPORT=1)
    set(CMAKE_CXX_STANDARD 17)
    fips_vs_warning_level(3)
    fips_deps(ari_core)
    fips_files(
        core.h                  core.cpp
        macros.h
    )
fips_end_module()

fips_begin_module(cari_en)
    add_definitions(-DARI_NO_MAIN=1 -DCARI_NO_EXPORT=1)
    set(CMAKE_CXX_STANDARD 17)
    fips_vs_warning_level(3)
    fips_deps(ari_en)
    fips_files(
        en.h                    en.cpp
        macros.h
    )
fips_end_module()

fips_begin_module(cari_gfx)
    add_definitions(-DARI_NO_MAIN=1 -DCARI_NO_EXPORT=1)
    set(CMAKE_CXX_STANDARD 17)
    fips_vs_warning_level(3)
    fips_deps(ari_gfx)
    fips_files(
        gfx.h                   gfx.cpp
        macros.h
    )
fips_end_module()

fips_begin_module(cari_gui)
    add_definitions(-DARI_NO_MAIN=1 -DCARI_NO_EXPORT=1 -DCIMGUI_NO_EXPORT)
    set(CMAKE_CXX_STANDARD 17)
    fips_vs_warning_level(3)
    fips_deps(ari_gui)
    fips_files(
        gui.h                   gui.cpp
        macros.h
    )
fips_end_module()

fips_begin_module(cari_io)
    add_definitions(-DARI_NO_MAIN=1 -DCARI_NO_EXPORT=1)
    set(CMAKE_CXX_STANDARD 17)
    fips_vs_warning_level(3)
    fips_deps(ari_fs_local)
    fips_files(
        io.h                    io.cpp
        macros.h
        zip_file.hpp
    )
fips_end_module()

fips_begin_module(cari_net)
    add_definitions(-DARI_NO_MAIN=1 -DCARI_NO_EXPORT=1)
    set(CMAKE_CXX_STANDARD 17)
    fips_vs_warning_level(3)
    fips_deps(ari_net)
    fips_files(
        macros.h
        net.h                   net.cpp
        netSerializer.hpp
    )
fips_end_module()

fips_begin_module(cari_net_3d)
    add_definitions(-DARI_NO_MAIN=1 -DCARI_NO_EXPORT=1)
    set(CMAKE_CXX_STANDARD 17)
    fips_vs_warning_level(3)
    fips_deps(ari_net ari_3d)
    fips_files(
        macros.h
        net3d.h                   net3d.cpp
    )
fips_end_module()
