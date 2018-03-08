# set build dir
BUILD_DIR := _build

# label them not file target
.PHONY: clean token myinterpreter

myinterpreter : token
	$(info Compiling myinterpreter...)
	@ghc -odir $(BUILD_DIR) -hidir $(BUILD_DIR) -o myinterpreter Main.hs

token: Token.x $(BUILD_DIR)
	$(info Compiling Token.x...)
	@alex Token.x -o $(BUILD_DIR)/Token.hs

$(BUILD_DIR):
	$(info Creating build directory...)
	@mkdir -p $(BUILD_DIR)

clean : 
	@rm -rf $(BUILD_DIR)
