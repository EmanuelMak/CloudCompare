ENV_FILE_NAME = .envrc
DOCKER_IMAGE_TAG ?= latest
updateVault:
	@echo "Updating Vault secrets..."
	npm run updateVault ./secrets.yaml 

setEnvLocal:
	@echo "Deleting shell script if exists..."
	rm -f ${ENV_FILE_NAME}
	@echo "Generating and setting local environment..."
	npm run setEnvLocal ./secrets.yaml ./settings.yaml ./vltSecret.yaml
	@echo "Running script..."
	chmod +x ${ENV_FILE_NAME}
	. ./${ENV_FILE_NAME}
	@echo "Script created at `pwd`/${ENV_FILE_NAME}. Remember to run 'source `pwd`/${ENV_FILE_NAME}' in your terminal."
	direnv allow
	cp ${ENV_FILE_NAME} ../${ENV_FILE_NAME}
	cd ..
	direnv allow

deleteVault:
	@echo "Deleting Vault secrets..."
	pm run deleteVaultSecrets ./secrets.yaml

fetchAndGenerateEnv:
	@echo "Fetching secrets from Vault..."
	chmod +x ${ENV_FILE_NAME}
	npm run fetchAndGenerateEnv ./settings.yaml ./vltSecret.yaml
	chmod +x ${ENV_FILE_NAME}
	. ./${ENV_FILE_NAME}
	direnv allow
	cp ${ENV_FILE_NAME} ../${ENV_FILE_NAME}
	cd ..
	direnv allow
# direnv:
# 	@echo "Installing direnv..."
# 	brew install direnv
# 	@echo "Adding direnv hook to your shell..."
# 	echo 'eval "$(direnv hook bash)"' >> ~/.bash_profile
# 	@echo "Adding direnv hook to your shell..."
# 	echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
# 	@echo "Adding direnv hook to your shell..."
# 	echo 'eval "$(direnv hook fish)"' >> ~/.config/fish/config.fish
# 	@echo "Adding direnv hook to your shell..."
# 	echo 'eval "$(direnv hook tcsh)"' >> ~/.tcshrc
# 	@echo "Adding direnv hook to your shell..."
#   direnv allow

# vlt commands: 
# 	vlt login
#	vlt config init
# 	vlt secrets get -plaintext {desired secret}
# 	vlt secrets

pushToGitLabRegistry:
	@. ./.envrc; \
	direnv allow; \
	export DOCKER_IMAGE_NAME=$$GIT_GITLAB_DOCKER_BASE_URL$$GIT_GITLAB_CLOUDCOMPARE_PATH; \
	docker login $$GIT_GITLAB_DOCKER_BASE_URL -u $$GIT_GITLAB_USERNAME -p $$GIT_GITLAB_CLOUDCOMPARE_TOKEN; \
	echo "Logging into GitLab's Container Registry..."; \
	echo GIT_GITLAB_CLOUDCOMPARE_TOKEN: $$GIT_GITLAB_CLOUDCOMPARE_TOKEN; \
	echo GIT_GITLAB_DOCKER_BASE_URL: $$GIT_GITLAB_DOCKER_BASE_URL; \
	echo GIT_GITLAB_CLOUDCOMPARE_PATH: $$GIT_GITLAB_CLOUDCOMPARE_PATH; \
	echo DOCKER_IMAGE_NAME: $$DOCKER_IMAGE_NAME; \
	echo GIT_GITLAB_USERNAME: $$GIT_GITLAB_USERNAME; \
	echo $$GIT_GITLAB_CLOUDCOMPARE_TOKEN | docker login $$GIT_GITLAB_DOCKER_BASE_URL -u $$GIT_GITLAB_USERNAME --password-stdin; \
	echo "Building Docker image..."; \
	docker build -t $$DOCKER_IMAGE_NAME .; \
	echo "Pushing Docker image to GitLab's Container Registry..."; \
	docker push $$DOCKER_IMAGE_NAME; \
	echo "Image pushed successfully!";


testVltSecretsCi:
	@echo "AWS ID: $$AWS_ID"
	@echo "AWS Password: $$AWS_PASSWORD"
	@echo "AWS User: $$AWS_USER"

.PHONY: updateVault setEnvLocal deleteVault pushToGitLabRegistry
