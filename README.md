# Verilog-RTL-Code-Generation-and-Verification-Based-on-LLM
Verilog RTL Code Generation and Verification Based on LLM
LLM-Based Verilog RTL Code Generation and Verification

This task involves selecting an existing open-source large language model (LLM) available in China to generate Verilog RTL design code and corresponding Verilog/SystemVerilog testbenches and scripts, based on given chip design specifications (such as functional descriptions and performance metrics). By providing prompt inputs to the LLM, participants are expected to generate functionally compliant design code. The generated code should be tested using simulation tools (e.g., Synopsys VCS) to ensure it meets design requirements. Each designated functional point must be effectively verified with proper test cases, and the code coverage must not fall below 95%. On top of that, participants are encouraged to further explore the integration of LLMs with EDA tools for automation of the verification process.

1. Participant Requirements:
Proficient in Verilog, with the ability to independently read and write RTL design code and build verification environments.

Solid understanding of digital circuit design fundamentals, including analysis and implementation capabilities.

Familiar with prompt engineering to generate RTL design code using LLMs.

2. Inputs and Outputs:
Input:
A design specification document for a frame format sequence detection and generation module will be provided.

Output:
a) Spec Design Document:
Within approximately one week, participants should analyze the provided requirements document and independently draft a complete and standards-compliant specification for the frame format sequence detection and generation module.

b) RTL Design Code:
Over the following two weeks, participants shall select an open-source LLM model and use prompt engineering techniques to generate RTL design code for the module.

c) Verification Environment and Workflow Description:
In the next two to three weeks, participants shall build the verification environment, testbenches, and scripts—either generated via the LLM or manually developed—and verify module functionalities. Any verification methodology is acceptable (e.g., Verilog testbench, SystemVerilog, or UVM). A clear description of the verification workflow and test execution must be provided.

d) Code Coverage Report:
Participants must submit a URG coverage report indicating that code coverage is no less than 95%.

e) LLM Prompting Log:
Participants must document the complete process of RTL (and verification environment) generation via LLM prompts. This includes saving the full log and screenshots of the final code generation as part of the deliverables.

Note: All time frames above are workload estimates and not strict deadlines.

3. Training Support:
Participants will receive theoretical training from Synopsys experts to better understand the fundamentals of large language models, prompt engineering techniques, and an in-depth explanation of the task requirements.

4. Module Design Requirements:
Based on the design of the frame format sequence detection and generation module, participants must elaborate on each functional feature in the Spec document (Output a), including frame parsing, CRC checking, asynchronous FIFO buffering, one-hot encoding, and channel selection.

5. Implementation and Verification:
Participants shall implement the defined functional features using LLM-generated RTL code (Output b), create a well-defined verification plan and feature list/test list, write test cases to verify all specified features, and provide a complete verification environment and scripts (Output c). Functional testing must ensure full feature coverage, and code coverage must reach at least 95%, with simulation results and coverage reports submitted (Output d). Furthermore, the entire LLM-based code generation process must be documented via logs and screenshots (Output e).

