TestBot = FactoryBot.dup
TestBot.reset_configuration
TestBot.definition_file_paths = ["spec/test_bot_factories"]
TestBot.reload
