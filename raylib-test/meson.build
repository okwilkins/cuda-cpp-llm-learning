project('raylib-test', ['cpp', 'c'],
  version : '0.1',
  default_options : [
    'cpp_std=c++23',
    'c_std=c99'
  ]
)

raylib_src = [
  'include/raylib/rcore.c',
  'include/raylib/rmodels.c',
  'include/raylib/rshapes.c',
  'include/raylib/rtext.c',
  'include/raylib/rtextures.c',
]

inc_dir = include_directories(
  'include/raylib',
)

cc = meson.get_compiler('c')
math_dep = cc.find_library('m', required : false)
glfw_dep = dependency('glfw3', required : false)
gl_dep = dependency('gl')
x11_dep = dependency('x11', required : false)

executable(
  'my_game',
  ['src/client.cpp'] + raylib_src,
  include_directories: inc_dir,
  dependencies: [math_dep, gl_dep, x11_dep, glfw_dep],
  c_args: ['-DPLATFORM_DESKTOP']
)

executable(
  'server',
  'src/server.cpp',
)
