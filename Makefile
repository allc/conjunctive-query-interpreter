# set build dir
BUILD_DIR := _build

# label them not file target
.PHONY : myinterpreter token clean test

myinterpreter : grammar
	$(info Compiling myinterpreter...)
	@ghc -i$(BUILD_DIR) -odir $(BUILD_DIR) -hidir $(BUILD_DIR) -o myinterpreter Main.hs

token : Token.x $(BUILD_DIR)
	$(info Compiling Token.x...)
	@alex Token.x -o $(BUILD_DIR)/Token.hs

grammar : token
	$(info Compiling Grammar.y...)
	@happy Grammar.y -o $(BUILD_DIR)/Grammar.hs
# to debug:
#happy Grammar.y -o _build/Grammar.hs -igrammer_info.txt

# modify this when testing out different things
test : grammar
	$(info Compiling test...)
	@ghc -i$(BUILD_DIR) -odir $(BUILD_DIR) -hidir $(BUILD_DIR) -o test Test.hs

$(BUILD_DIR) :
	$(info Creating build directory...)
	@mkdir -p $(BUILD_DIR)

clean :
	$(info Removing $(BUILD_DIR))
	@rm -rf $(BUILD_DIR)
