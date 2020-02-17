
ExternalProject_Add(cura-binary-data
    SOURCE_DIR /home/BCN3D/epardo/Projects/Cura2/cura-binary-data
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
)

SetProjectDependencies(TARGET cura-binary-data DEPENDS Cura)
