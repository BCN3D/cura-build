# Signing the Installer and Cura.exe with "signtool.exe"
# Location on my desktop:
# -> C:\Program Files (x86)\Windows Kits\10\bin\x86\signtool.exe
# * Manual: https://msdn.microsoft.com/de-de/library/8s9b9yaz(v=vs.110).aspx

find_package(Signtool REQUIRED)

set(WINDOWS_IDENTITIY_PFX_FILE "" CACHE STRING "PFX file, which represents the identity of the developer.")
set(WINDOWS_IDENTITIY_PFX_PASSWORD "" CACHE STRING "Password, which unlocks the PFX file (optional)")
set(WINDOWS_SIGN_TOKEN_CERT_THUMBPRINT "" CACHE STRING "Certificate thumbprint, which is contained inside a sign token and represents the identity of the developer.")

if(EXISTS ${WINDOWS_IDENTITIY_PFX_FILE})
    set(signtool_OPTIONS /fd SHA256 /a /f ${WINDOWS_IDENTITIY_PFX_FILE})
    if(NOT ${WINDOWS_IDENTITIY_PFX_PASSWORD} EQUAL "")
        set(signtool_OPTIONS ${signtool_OPTIONS} /p ${WINDOWS_IDENTITIY_PFX_PASSWORD})
    else()
        message(FATAL_ERROR "You can't sign your executables without passing your password here!") # Sadly...
    endif()
    message(STATUS "Signing executables with: " ${WINDOWS_IDENTITIY_PFX_FILE})
    if(${WINDOWS_IDENTITIY_PFX_PASSWORD})
        message(WARNING "USE WITH CAUTION: Password for the PFX file has been set!")
    endif()
elseif(NOT ${WINDOWS_SIGN_TOKEN_CERT_THUMBPRINT} EQUAL "")
    set(signtool_OPTIONS /tr http://timestamp.digicert.com /td sha256 /fd sha256 /sha1 ${WINDOWS_SIGN_TOKEN_CERT_THUMBPRINT})
    message(STATUS "Signing executables with certificate: " ${WINDOWS_SIGN_TOKEN_CERT_THUMBPRINT})
else()
    message(WARNING "Could not find the PFX file and the certificate thumbprint is not set. Can not sign the executables!")
    return()
endif()

# Signing Cura.exe
add_custom_command(
    TARGET signing PRE_BUILD
    COMMAND ${SIGNTOOL_EXECUTABLE} sign ${signtool_OPTIONS} BCN3D_Cura.exe
    ## Other optional options:
    # /tr timestampServerUrl 
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/package
)

# Signing CuraEngine.exe
add_custom_command(
    TARGET signing PRE_BUILD
    COMMAND ${SIGNTOOL_EXECUTABLE} sign ${signtool_OPTIONS} CuraEngine.exe
    ## Other optional options:
    # /tr timestampServerUrl 
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/package
)

# Signing the installer
add_custom_target(signing-installer) # Sadly "TARGET package POST_BUILD" can't be used in the following add_custom_command()
if(${BUILD_OS_WIN32})
    set(CURA_INSTALLER_NAME ${CPACK_NSIS_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_SYSTEM_NAME}.exe)
else()
    # TODO: Verify whether ${CPACK_SYSTEM_NAME} is "win64", when doing 64bit builds.
    set(CURA_INSTALLER_NAME ${CPACK_NSIS_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-win64.exe)
endif()
add_custom_command(
    TARGET signing-installer
    COMMAND ${SIGNTOOL_EXECUTABLE} sign ${signtool_OPTIONS} ${CURA_INSTALLER_NAME}
    ## Other optional options:
    # /tr timestampServerUrl 
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)