PARROT=parrot.sh
all:
	./mk-tsan1
	./mk-tsan2
	if [ -f mk-relay ]; then ./mk-relay; fi
$(PARROT):tsan1/$(EXE)
	@echo "LD_PRELOAD=$(XTERN_ROOT)/dync_hook/interpose.so ./tsan1/$(EXE) $(ARGS)" > $(PARROT)
	@chmod +x $(PARROT)
none:tsan1/$(EXE)
	@echo "        ------Nothing------"
	-$(PRECMD)\
	./tsan1/$(EXE) $(ARGS)\
	$(POSTCMD)
tsan1:tsan1/$(EXE)
	@echo "        ------Thread Sanitizer------Pure Happens-Before"
	-$(PRECMD)\
	$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=tsan ./tsan1/$(EXE) $(ARGS)\
	$(POSTCMD)
	@grep "ThreadSanitizer summary" $@.log
tsan1-hybrid:tsan1/$(EXE)
	@echo "        ------Thread Sanitizer------Hybrid"
	$(PRECMD)
	-$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=tsan --hybrid=yes ./tsan1/$(EXE) $(ARGS)
	$(POSTCMD)
	@grep "ThreadSanitizer summary" $@.log
helgrind:tsan1/$(EXE)
	@echo "        ------Helgrind------Happens-Before"
	$(PRECMD)
	-$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=helgrind ./tsan1/$(EXE) $(ARGS)
	$(POSTCMD)
	@grep "ERROR SUMMARY" $@.log
parrot-tsan1:$(PARROT)
	@echo "        ------Thread Sanitizer------Pure Happens-Before--------PARROT!!!!!!!!"
	$(PRECMD)
	-$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/parrot-tsan.supp --tool=tsan ./$(PARROT)
	$(POSTCMD)
	@grep "ThreadSanitizer summary" $@.log
parrot-tsan1-hybrid:$(PARROT)
	@echo "        ------Thread Sanitizer------Hybrid---------------------PARROT!!!!!!!!"
	$(PRECMD)
	-$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/parrot-tsan.supp --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/parrot-tsan-hybrid.supp --tool=tsan --hybrid=yes ./$(PARROT)
	$(POSTCMD)
	@grep "ThreadSanitizer summary" $@.log
parrot-helgrind:$(PARROT)
	@echo "        ------Helgrind------Happens-Before---------------------PARROT!!!!!!!!"
	$(PRECMD)
	-$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/install/bin/valgrind --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/parrot-helgrind.supp --trace-children=yes --read-var-info=yes --log-file=$@.log --suppressions=$(DATA_RACE_DETECTION_ROOT)/thread-sanitizer/libc.supp --tool=helgrind ./$(PARROT)
	$(POSTCMD)
	@grep "ERROR SUMMARY" $@.log
tsan2:tsan2/$(EXE)
	@echo "        ------Thread Sanitizer version 2------"
	$(PRECMD)
	-TSAN_OPTIONS="log_path=tsan2.log" ./tsan2/$(EXE) $(ARGS)
	$(POSTCMD)
	mv tsan2.log.* tsan2.log
	@grep "warnings" $@.log
relay:relay/$(DIR)/ciltrees
	@echo "        ------Relay Static Analyzer------"
	-PWD=`pwd`;\
	cd $(DATA_RACE_DETECTION_ROOT)/relay/relay-radar;\
	./relay_single.sh ${PWD}/relay/$(DIR)/ciltrees > /dev/null
	@cp relay/$(DIR)/ciltrees/log.relay relay.log
	@grep "Total Warnings:" relay.log
detect:tsan1 tsan1-hybrid tsan2
	@if [ -f mk-relay ]; then make relay; fi
detect-all:tsan1 parrot-tsan1 tsan1-hybrid parrot-tsan1-hybrid helgrind parrot-helgrind tsan2
	@if [ -f mk-relay ]; then make relay; fi
clean:
	rm -rf tsan1 tsan2 relay $(PARROT) *.log* dump.options
.PHONY: all clean tsan1 tsan2 relay
