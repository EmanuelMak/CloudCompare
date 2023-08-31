
pushToGitLabRegistry:
	@vlt run --command="make -f makefile.ci pushToGitLabRegistry USECASE=$$USECASE"

pushBaseImageToGitLabRegistry:
	@make  pushToGitLabRegistry USECASE=base

pushjdkmvnImageToGitLabRegistry:
	@make  pushToGitLabRegistry USECASE=jdkmvn