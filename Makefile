APP=eredis

DIALYZER_OPTS=-Werror_handling -Wrace_conditions -Wunmatched_returns

DIALYZER_PLT=.dialyzer.plt

.PHONY: all compile clean Emakefile

all: compile

compile: ebin/$(APP).app Emakefile
	erl -noinput -eval 'up_to_date = make:all()' -s erlang halt

clean:
	rm -f -- ebin/*.beam Emakefile ebin/$(APP).app

ebin/$(APP).app: src/$(APP).app.src
	mkdir -p ebin
	cp -f -- $< $@

ifdef DEBUG
EXTRA_OPTS:=debug_info,
endif

ifdef TEST
EXTRA_OPTS:=$(EXTRA_OPTS) {d,'TEST', true},
endif

Emakefile: Emakefile.src
	sed "s/{{EXTRA_OPTS}}/$(EXTRA_OPTS)/" $< > $@

.dialyzer.plt:
	touch $(DIALYZER_PLT)
	dialyzer --build_plt --plt $(DIALYZER_PLT) --apps erts \
		$(shell erl -noshell -pa ebin -eval '{ok, _} = application:ensure_all_started($(APP)), [erlang:display(Name) || {Name, _, _} <- application:which_applications(), Name =/= $(APP)], halt().')

dialyzer: .dialyzer.plt
	dialyzer --no_native -pa ebin --plt $(DIALYZER_PLT) -r ebin $(DIALYZER_OPTS)
