SRC=micro4.cpp
EXE=micro4
ARGS=
all:$(SRC)
	g++ -g -O0 $(SRC) -o $(EXE) -lpthread
tsan-test:all
	@echo "        ------Thread Sanitizer------Pure Happens-Before"
	-$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=tsan ./$(EXE) $(ARGS) 2>&1 | grep "ThreadSanitizer summary"
tsan-hybrid-test:all
	@echo "        ------Thread Sanitizer------Hybrid"
	-$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=tsan --hybrid=yes ./$(EXE) $(ARGS) 2>&1 | grep "ThreadSanitizer summary"
helgrind:all
	@echo "        ------Helgrind------Happens-Before"
	-$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=helgrind ./$(EXE) $(ARGS) 2>&1 | grep "ERROR SUMMARY"
test:tsan-test tsan-hybrid-test helgrind
clean:
	rm $(EXE)
