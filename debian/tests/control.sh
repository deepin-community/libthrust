#!/bin/sh

CR="
"

cat <<EoF
Test-Command: cmake -Wno-dev -S debian/tests/cmake -B \$AUTOPKGTEST_TMP
Features: test-name=cmake_find_package_Thrust
Depends:
 @,
 cmake,
 g++,
 libtbb-dev,
Restrictions:
 superficial,

EoF

emit_normal()
{
	local dev="$1"
	local std="${2:-17}"
	local cxx="$3"
	local dep="${cxx:-g++}"
	local name=$(echo "run_testsuite_${dev}_C++${std}${cxx:+_$cxx}" | tr / _)
	cat <<EoF
Test-Command: debian/tests/upstream-testsuite ${dev} ${std}${cxx:+ $cxx}
Features: test-name=${name}
Depends:
 @,
 cmake,
 make,
 libtbb-dev,
 $dep,
Restrictions:
 superficial,
 allow-stderr,
 flaky,

EoF
}

emit_cuda()
{
	local dev="$1"
	local std="${2:-17}"
	local cxx="$3"
	local dep="${cxx:-g++},${CR} nvidia-cuda-toolkit-gcc"
	local flaky="${CR} flaky,"
	local skippable="${CR} skippable,"
	case $cxx in
		cuda-g++)
			dep="nvidia-cuda-toolkit-gcc"
			test "$dev" = "TBB/CUDA" || flaky=
			skippable=
			;;
	esac
	local name=$(echo "compile_testsuite_${dev}_C++${std}${cxx:+_$cxx}" | tr / _)
	cat <<EoF
Test-Command: debian/tests/upstream-testsuite ${dev} ${std}${cxx:+ $cxx}
Features: test-name=${name}
Architecture: amd64
Depends:
 @,
 cmake,
 make,
 libtbb-dev,
 ${dep},
Restrictions:
 superficial,
 allow-stderr,${flaky}${skippable}

EoF
}

emit_normal CPP 17 g++-12
emit_normal CPP 17 g++-11
emit_normal CPP 14
emit_normal TBB

for DEVICE in CUDA; do
	for CXX in cuda-g++ g++-11 ; do
		for STD in 17 ; do
			for HOST in CPP TBB ; do
				emit_cuda ${HOST}/${DEVICE} ${STD} ${CXX}
			done
		done
	done
done
