
pushToGitLabRegistry:
	@vlt run --command="make -f makefile.ci pushToGitLabRegistry USECASE=$$USECASE"

pushBaseImageToGitLabRegistry:
	@make  pushToGitLabRegistry USECASE=base

pushjdkmvnImageToGitLabRegistry:
	@make  pushToGitLabRegistry USECASE=jdkmvn

pushdockerImageToGitLabRegistry:
	@make  pushToGitLabRegistry USECASE=docker

pushawsebImageToGitLabRegistry:
	@make  pushToGitLabRegistry USECASE=awseb

pushazureImageToGitLabRegistry:
	@make  pushToGitLabRegistry USECASE=azure
pushawsecsImageToGitLabRegistry:
	@make  pushToGitLabRegistry USECASE=awsecs


