cmake_minimum_required(VERSION 3.15)

project(find_thrust CXX)

find_package(Thrust REQUIRED CONFIG)
thrust_create_target(Thrust)
thrust_create_target(ThrustCUDA DEVICE CUDA)
thrust_create_target(ThrustTBB DEVICE TBB)
thrust_create_target(ThrustOMP DEVICE OMP)
