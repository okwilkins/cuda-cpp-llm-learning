project(
  'raylib-test',
  ['cpp', 'c'],
  version : '0.1',
  default_options : [
    'cpp_std=c++23',
    'c_std=c99',
    'buildtype=release',
  ]
)

raylib_src = [
  'extern/raylib/rcore.c',
  'extern/raylib/rmodels.c',
  'extern/raylib/rshapes.c',
  'extern/raylib/rtext.c',
  'extern/raylib/rtextures.c',
]

extern_dir = include_directories(
  'extern/raylib',
  'extern/asio/include'
)

include_dir = include_directories('src/include')

cc = meson.get_compiler('c')
math_dep = cc.find_library('m', required : false)
glfw_dep = dependency('glfw3', required : false)
gl_dep = dependency('gl')
x11_dep = dependency('x11', required : false)

raylib_lib = static_library(
  'raylib',
  raylib_src,
  include_directories: extern_dir,
  c_args: ['-DPLATFORM_DESKTOP'],
  dependencies: [math_dep, gl_dep, glfw_dep, x11_dep],
  install: false,
)

executable(
  'my_game',
  ['src/client.cpp'],
  include_directories: [extern_dir, include_dir],
  link_with: raylib_lib,
  dependencies: [math_dep, gl_dep, x11_dep, glfw_dep],
)

executable(
  'server',
  ['src/server.cpp'],
  include_directories: [extern_dir, include_dir],
)
