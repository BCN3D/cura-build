ExternalProject_Add(cura-binary-data
    SOURCE_DIR C:/Users/epardo/Documents/Projects/Cura/cura-binary-data
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
)

SetProjectDependencies(TARGET cura-binary-data DEPENDS Cura)