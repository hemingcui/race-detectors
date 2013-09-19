SRC=micro4.cpp
EXE=micro4
ARGS=
PARROT=parrot.sh
all:$(SRC)
	g++ -g -O0 $(SRC) -o $(EXE) -lpthread
$(PARROT):all
	@echo "LD_PRELOAD=$(XTERN_ROOT)/dync_hook/interpose.so ./$(EXE) $(ARGS)" > $(PARROT)
	@chmod +x $(PARROT)
tsan:all
	@echo "        ------Thread Sanitizer------Pure Happens-Before"
	@$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=tsan ./$(EXE) $(ARGS)
	@grep "ThreadSanitizer summary" $@.log
tsan-hybrid:all
	@echo "        ------Thread Sanitizer------Hybrid"
	@$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=tsan --hybrid=yes ./$(EXE) $(ARGS)
	@grep "ThreadSanitizer summary" $@.log
helgrind:all
	@echo "        ------Helgrind------Happens-Before"
	@$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=helgrind ./$(EXE) $(ARGS)
	@grep "ERROR SUMMARY" $@.log
parrot-tsan:$(PARROT)
	@echo "        ------Thread Sanitizer------Pure Happens-Before--------PARROT!!!!!!!!"
	@$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=tsan ./$(PARROT)
	@grep "ThreadSanitizer summary" $@.log
parrot-tsan-hybrid:$(PARROT)
	@echo "        ------Thread Sanitizer------Hybrid---------------------PARROT!!!!!!!!"
	@$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=tsan --hybrid=yes ./$(PARROT)
	@grep "ThreadSanitizer summary" $@.log
parrot-helgrind:$(PARROT)
	@echo "        ------Helgrind------Happens-Before---------------------PARROT!!!!!!!!"
	@$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=helgrind ./$(PARROT)
	@grep "ERROR SUMMARY" $@.log
test:tsan parrot-tsan tsan-hybrid parrot-tsan-hybrid helgrind parrot-helgrind
clean:
	rm -rf $(EXE) $(PARROT) *.log
.PHONY:
	clean all
