function(default_exec marco_name marco execname)
    if ("${marco}" STREQUAL "")
        find_program(${execname}_EXEC "${execname}" REQUIRED)
        message("Found executable `${execname}` (${${execname}_EXEC}). Manual override marco `${marco_name}`.")
        set(${marco_name} "${${execname}_EXEC}" PARENT_SCOPE)
    else()
        message("Executable `${execname}` overridden by `${marco}`.")
    endif()
endfunction()

function(default_flags marco_name marco flag_name)
    if ("${marco}" STREQUAL "")
        set(${marco_name} "${flag_name}" PARENT_SCOPE)
    endif()
endfunction()