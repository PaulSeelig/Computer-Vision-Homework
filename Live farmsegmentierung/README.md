# ROS2 C++ Exercise: Parameterized Person Talker and Distinct-Entry Listener

This exercise guides students from an empty ROS2 C++ package to the final
`ros2_person_exchange` implementation:

- a custom `PersonInfo` message,
- a C++ talker node that publishes parameter values periodically,
- a C++ listener node that subscribes and prints all distinct received entries.

It is designed to be used alongside the official ROS2 Jazzy tutorials:

- Tutorial index: <https://docs.ros.org/en/jazzy/Tutorials.html>
- Using `colcon`: <https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Colcon-Tutorial.html>
- C++ publisher/subscriber: <https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Cpp-Publisher-And-Subscriber.html>
- Custom interfaces in one package: <https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Single-Package-Define-And-Use-Interface.html>
- Parameters in C++: <https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Using-Parameters-In-A-Class-CPP.html>

## Learning Goals

By the end, students should be able to:

- create and build an `ament_cmake` ROS2 package,
- define a custom `.msg` interface,
- configure `package.xml` and `CMakeLists.txt` for generated messages,
- write a publisher node in C++,
- write a subscriber node in C++,
- use ROS2 parameters from C++,
- inspect topics, interfaces, nodes, and parameters with the ROS2 CLI,
- store application state inside a subscriber node.

## Starting Point

Concepts:

- installation
- workspace

Official tutorial:

- Creating a workspace

Task:

As the starting point for this exercise, you need to install ROS2 Jazzy (or another ROS2 distribution, if Jazzy is not available for your system). Follow the installation guide on: https://docs.ros.org/en/jazzy/Installation.html or the respective installation guide for your chosen distribution.

After ROS2 is successfully installed, the next step is to create a workspace for your ROS2 packages. Simply create a directory (e.g. ros2_ws or choose another name) at any location on your system. **Remark:** the following instructions assume you created the workspace in your home directory (~/). If you chose another location, you need to use this path accordingly.

```bash
cd ~
mkdir ros2_ws
```

## Step 1: Create the Package

Concepts:

- ROS2 workspace layout
- packages
- `ament_cmake`
- package dependencies

Official tutorial:

- Using `colcon` to build packages
- Creating a package

Task:

Create a package named `ros2_person_exchange`:

```bash
cd ~/ros2_ws/src
ros2 pkg create --build-type ament_cmake ros2_person_exchange \
  --dependencies rclcpp
```

Expected files:

```text
ros2_person_exchange/
  CMakeLists.txt
  package.xml
  src/
```

Build check:

```bash
cd ~/ros2_ws
colcon build --packages-select ros2_person_exchange
source install/setup.bash
```

Checkpoint questions:

- What is the difference between the workspace root and a package directory?
- Why is `rclcpp` needed for C++ ROS2 nodes?
- Where do build artifacts, installed files, and logs appear after `colcon build`?

## Step 2: Add a Minimal Talker Node

Concepts:

- nodes
- publishers
- timers
- `rclcpp::Node`

Official tutorial:

- Writing a simple publisher and subscriber (C++)

Task:

Create `src/person_talker.cpp`.

Start with a node class named `PersonTalker` that:

- inherits from `rclcpp::Node`,
- creates a wall timer,
- logs a message periodically with `RCLCPP_INFO`.

Update `CMakeLists.txt`:

- add an executable named `person_talker`,
- link it with `rclcpp`,
- install it into `lib/${PROJECT_NAME}`.

Build and run:

```bash
cd ~/ros2_ws
colcon build --packages-select ros2_person_exchange
source install/setup.bash
ros2 run ros2_person_exchange person_talker
```

Checkpoint questions:

- What does `rclcpp::spin(...)` do?
- Why does the node keep running after `main()` creates it?
- What is the role of the timer callback?

## Step 3: Define the Custom Message

Concepts:

- interfaces
- `.msg` files
- generated C++ message headers
- ROS2 field naming rules

Official tutorial:

- Implementing custom interfaces

Task:

Create a directory and message file:

```bash
cd ~/ros2_ws/src/ros2_person_exchange
mkdir msg
touch msg/PersonInfo.msg
```

Define the message:

```msg
string firstname
string surname
int32 age
string bachelor_course
```

Notes:

- ROS2 message type names use `string`, not `str`.
- Field names should be lower snake case, so `Bachelor course` becomes
  `bachelor_course`.

Update `package.xml`:

```xml
<build_depend>rosidl_default_generators</build_depend>
<exec_depend>rosidl_default_runtime</exec_depend>
<member_of_group>rosidl_interface_packages</member_of_group>
```

Update `CMakeLists.txt`:

```cmake
find_package(rosidl_default_generators REQUIRED)

rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/PersonInfo.msg"
)

ament_export_dependencies(rosidl_default_runtime)
```

Build and inspect:

```bash
cd ~/ros2_ws
colcon build --packages-select ros2_person_exchange
source install/setup.bash
ros2 interface show ros2_person_exchange/msg/PersonInfo
```

Expected output:

```text
string firstname
string surname
int32 age
string bachelor_course
```

Checkpoint questions:

- Why does a `.msg` file require code generation before C++ can use it?
- What generated header corresponds to `PersonInfo.msg`?
- Why is `bachelor_course` valid while `Bachelor course` is not?

## Step 4: Publish the Custom Message

Concepts:

- typed publishers
- topic names
- generated message headers

Official tutorial:

- Writing a simple publisher and subscriber (C++)
- Implementing custom interfaces

Task:

Extend `src/person_talker.cpp` so that it:

- includes the generated message header,
- creates a publisher for `ros2_person_exchange::msg::PersonInfo`,
- publishes on topic `person_info`,
- fills the message with hard-coded values at first.

Update `CMakeLists.txt` so the executable links against the generated message
type support:

```cmake
rosidl_get_typesupport_target(cpp_typesupport_target
  ${PROJECT_NAME} "rosidl_typesupport_cpp")

target_link_libraries(person_talker "${cpp_typesupport_target}")
```

Build and inspect the topic:

```bash
cd ~/ros2_ws
colcon build --packages-select ros2_person_exchange
source install/setup.bash
ros2 run ros2_person_exchange person_talker
```

In another terminal source your ROS2 installation and:

```bash
cd ~/ros2_ws
source install/setup.bash
ros2 topic list
ros2 topic echo /person_info
```

Checkpoint questions:

- Why does the publisher need the generated message header?
- What happens if the topic name in `ros2 topic echo` is wrong?
- What does the queue size argument in `create_publisher(..., 10)` mean?

## Step 5: Add a Listener Node

Concepts:

- subscribers
- callbacks
- receiving typed messages

Official tutorial:

- Writing a simple publisher and subscriber (C++)

Task:

Create `src/person_listener.cpp`.

Implement a node named `PersonListener` that:

- inherits from `rclcpp::Node`,
- subscribes to `person_info`,
- receives `ros2_person_exchange::msg::PersonInfo`,
- prints `firstname`, `surname`, `age`, and `bachelor_course`.

Update `CMakeLists.txt`:

- add executable `person_listener`,
- link it with `rclcpp`,
- link it with the generated type support,
- install it.

Build the package and run:

Terminal 1:

```bash
cd ~/ros2_ws
source install/setup.bash
ros2 run ros2_person_exchange person_listener
```

Terminal 2:

```bash
cd ~/ros2_ws
source install/setup.bash
ros2 run ros2_person_exchange person_talker
```

Checkpoint questions:

- Why must publisher and subscriber use the same message type?
- What happens if the topic names differ?
- Why is the callback only called after messages arrive?

## Step 6: Replace Hard-Coded Values with ROS2 Parameters

Concepts:

- parameters
- command-line parameter overrides
- runtime parameter inspection

Official tutorial:

- Using parameters in a class (C++)
- Understanding parameters

Task:

Extend `PersonTalker` so that it declares these parameters:

```text
firstname
surname
age
bachelor_course
publish_period_ms
```

Suggested defaults:

```text
firstname: Ada
surname: Lovelace
age: 28
bachelor_course: Computer Science
publish_period_ms: 1000
```

Use the parameter values when filling the published `PersonInfo` message.

Run with custom parameters (use your own data if you like). Fill in the values in the following command after := :

```bash
ros2 run ros2_person_exchange person_talker --ros-args \
  -p firstname:= \
  -p surname:= \
  -p age:= \
  -p bachelor_course:= \
  -p publish_period_ms:=
```

Inspect parameters:

```bash
ros2 param list
ros2 param get /person_talker firstname
ros2 param get /person_talker bachelor_course
```

Optional runtime update:

```bash
ros2 param set /person_talker firstname Alan
ros2 param set /person_talker surname Turing
ros2 param set /person_talker age 41
ros2 param set /person_talker bachelor_course Mathematics
```

Checkpoint questions:

- What is the difference between a hard-coded value and a ROS2 parameter?
- When are parameters declared?
- How can a launch file later reuse these same parameters?

## Step 7: Store Distinct Received Entries

Concepts:

- subscriber-side state
- C++ containers
- duplicate detection
- summary output

Task:

Extend `PersonListener` so that it keeps a summary of all distinct received
entries.

One possible design:

- create a small `PersonInfoEntry` struct,
- store entries in `std::set<PersonInfoEntry>`,
- define `operator<` so the set can order and deduplicate entries,
- print the full list after every received message.

Expected behavior:

- The first time a person/course combination is received, it is added.
- If the same combination arrives again, it is treated as a duplicate.
- The listener prints the complete distinct summary list.

Example summary:

```text
Summary of distinct received information (2):
  1. Ada Lovelace, age 28, Bachelor course: Computer Science
  2. Alan Turing, age 41, Bachelor course: Mathematics
```

Checkpoint questions:

- What makes two entries equal in this exercise?
- Why is `std::set` convenient for duplicate detection?
- How would behavior change if only `firstname` and `surname` were used for
  uniqueness?

## Step 8: Use ROS2 CLI Tools to Inspect the System

Concepts:

- ROS graph introspection
- topics
- nodes
- interfaces
- parameters

Official tutorials:

- Understanding nodes
- Understanding topics
- Understanding parameters

Useful commands:

```bash
ros2 node list
ros2 node info /person_talker
ros2 node info /person_listener

ros2 topic list
ros2 topic info /person_info
ros2 topic echo /person_info

ros2 interface show ros2_person_exchange/msg/PersonInfo

ros2 param list
ros2 param describe /person_talker firstname
```

Student task:

Write down which command answers each question:

- Which nodes are running?
- Which topic connects the two nodes?
- Which message type does the topic use?
- Which parameters can configure the talker?
- What happens in the listener when the talker parameters change?

## Step 9: Suggested Extensions

These are optional exercises for faster students or follow-up sessions.

1. Add a launch file

   Create a launch file that starts both nodes and passes talker parameters.
   Compare with the official launch tutorials.

2. Add input validation

   Reject negative ages or empty names in the talker.

3. Add a timestamp

   Extend the message with a timestamp field and discuss when message contents
   should include time.

4. Split interfaces into a separate package

   Move `PersonInfo.msg` into a dedicated interface package and make the talker
   and listener depend on it.

5. Add a service

   Add a service to the listener that clears the summary list.

6. Add tests

   Use launch testing or GTest to verify that messages are exchanged.