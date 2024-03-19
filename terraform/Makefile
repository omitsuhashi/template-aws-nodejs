.PHONY: init plan apply destroy workspace validate_workspace

# 許可されたワークスペースのリスト
VALID_WORKSPACES := dev stg prod

# デフォルトのworkspace
WORKSPACE ?= dev

# Terraform コマンドを実行するための関数定義
define terraform_cmd
@if [ "$(WORKSPACE)" = "dev" ]; then \
	cd ./local && terraform $(1); \
else \
	cd ./cloud && terraform $(1); \
fi
endef

# Terraform初期化
init:
	$(call terraform_cmd,init)

# Terraformプラン
plan: validate_workspace workspace
	$(call terraform_cmd,plan)

# Terraform適用
apply: validate_workspace workspace
	$(call terraform_cmd,apply)

# Terraform破棄
destroy: validate_workspace workspace
	$(call terraform_cmd,destroy)

# Workspaceの選択または変更
workspace:
	@echo "Switching to workspace $(WORKSPACE)..."
	terraform workspace select $(WORKSPACE) || terraform workspace new $(WORKSPACE)

# ワークスペースの検証
validate_workspace:
	@if ! echo "$(VALID_WORKSPACES)" | grep -wq "$(WORKSPACE)"; then \
			echo "Invalid workspace: $(WORKSPACE). Valid workspaces are: $(VALID_WORKSPACES)"; \
			exit 1; \
	fi
