#!/bin/bash

# Agent OS Installation Script
# This script installs Agent OS files from the GitHub repository into your workspace

set -e  # Exit on error

# Configuration
GH_REPO="https://raw.githubusercontent.com/Tuanm/.copilot-agent-os/refs/heads/main"
INSTALL_DIR="."
OVERWRITE_ALL=false
SKIP_ALL=false
FORCE_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_MODE=true
            shift
            ;;
        -h|--help)
            echo "Usage: bash <(curl -sSL https://raw.githubusercontent.com/Tuanm/.copilot-agent-os/refs/heads/main/install.sh)"
            echo ""
            echo "Options:"
            echo "  -f, --force    Install without prompting (overwrite all files)"
            echo "  -h, --help     Show this help message"
            echo ""
            echo "Example:"
            echo "  bash <(curl -sSL https://raw.githubusercontent.com/Tuanm/.copilot-agent-os/refs/heads/main/install.sh)"
            echo "  bash <(curl -sSL https://raw.githubusercontent.com/Tuanm/.copilot-agent-os/refs/heads/main/install.sh) --force"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}▸${NC} $1"
}

# Ask for overwrite confirmation
ask_overwrite() {
    local file="$1"

    # If force mode is enabled, always overwrite
    if [ "$FORCE_MODE" = true ]; then
        return 0
    fi

    # If user chose to overwrite/skip all, respect that choice
    if [ "$OVERWRITE_ALL" = true ]; then
        return 0
    fi
    if [ "$SKIP_ALL" = true ]; then
        return 1
    fi

    # Ask for this specific file
    echo -e "${YELLOW}File exists: $file${NC}"
    echo -n "Overwrite? [y]es, [n]o, [a]ll, [s]kip all: "
    read -r response

    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        [aA]|[aA][lL][lL])
            OVERWRITE_ALL=true
            return 0
            ;;
        [sS]|[sS][kK][iI][pP])
            SKIP_ALL=true
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

# Download file function
download_file() {
    local source_path="$1"
    local target_path="$2"
    local url="${GH_REPO}/${source_path}"

    # Check if file already exists
    if [ -f "$target_path" ]; then
        if ! ask_overwrite "$target_path"; then
            print_warning "Skipped: $target_path"
            return 0
        fi
    fi

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target_path")"

    # Download the file
    if curl -fsSL "$url" -o "$target_path" 2>/dev/null; then
        print_success "Installed: $target_path"
        return 0
    else
        print_error "Failed to download: $source_path"
        return 1
    fi
}

# Main installation function
install_agent_os() {
    print_header "Installing Agent OS"

    # Ask for initial confirmation (unless in force mode)
    if [ "$FORCE_MODE" = false ]; then
        echo ""
        echo "This will install Agent OS files into your current directory:"
        echo "  - .github/agents/ (8 agent files)"
        echo "  - .github/prompts/ (6 prompt files)"
        echo "  - .github/copilot-instructions.md"
        echo "  - agent-os/ (configuration and standards)"
        echo ""
        echo -n "Do you want to continue? [y/N]: "
        read -r response
        case "$response" in
            [yY]|[yY][eE][sS])
                echo ""
                ;;
            *)
                print_warning "Installation cancelled by user"
                exit 0
                ;;
        esac
    else
        print_warning "Running in force mode - all existing files will be overwritten"
    fi

    # Create necessary directories
    print_info "Creating directory structure..."
    mkdir -p .github/agents
    mkdir -p .github/prompts
    mkdir -p agent-os/standards/backend
    mkdir -p agent-os/standards/frontend
    mkdir -p agent-os/standards/global
    mkdir -p agent-os/standards/testing
    mkdir -p agent-os/product
    mkdir -p agent-os/specs

    # Download core configuration files
    print_info "Installing core configuration files..."
    download_file ".github/copilot-instructions.md" ".github/copilot-instructions.md"
    download_file "agent-os/config.yml" "agent-os/config.yml"

    # Download agent files
    print_info "Installing agent definitions..."
    download_file ".github/agents/implementation-verifier.agent.md" ".github/agents/implementation-verifier.agent.md"
    download_file ".github/agents/implementer.agent.md" ".github/agents/implementer.agent.md"
    download_file ".github/agents/product-planner.agent.md" ".github/agents/product-planner.agent.md"
    download_file ".github/agents/spec-initializer.agent.md" ".github/agents/spec-initializer.agent.md"
    download_file ".github/agents/spec-shaper.agent.md" ".github/agents/spec-shaper.agent.md"
    download_file ".github/agents/spec-verifier.agent.md" ".github/agents/spec-verifier.agent.md"
    download_file ".github/agents/spec-writer.agent.md" ".github/agents/spec-writer.agent.md"
    download_file ".github/agents/tasks-list-creator.agent.md" ".github/agents/tasks-list-creator.agent.md"

    # Download prompt files
    print_info "Installing prompts..."
    download_file ".github/prompts/plan-product.prompt.md" ".github/prompts/plan-product.prompt.md"
    download_file ".github/prompts/create-tasks.prompt.md" ".github/prompts/create-tasks.prompt.md"
    download_file ".github/prompts/orchestrate-tasks.prompt.md" ".github/prompts/orchestrate-tasks.prompt.md"
    download_file ".github/prompts/write-spec.prompt.md" ".github/prompts/write-spec.prompt.md"
    download_file ".github/prompts/shape-spec.prompt.md" ".github/prompts/shape-spec.prompt.md"
    download_file ".github/prompts/implement-tasks.prompt.md" ".github/prompts/implement-tasks.prompt.md"

    # Download standards files
    print_info "Installing coding standards..."

    # Backend standards
    download_file "agent-os/standards/backend/api.md" "agent-os/standards/backend/api.md" || true
    download_file "agent-os/standards/backend/migrations.md" "agent-os/standards/backend/migrations.md" || true
    download_file "agent-os/standards/backend/models.md" "agent-os/standards/backend/models.md" || true
    download_file "agent-os/standards/backend/queries.md" "agent-os/standards/backend/queries.md" || true

    # Frontend standards
    download_file "agent-os/standards/frontend/accessibility.md" "agent-os/standards/frontend/accessibility.md" || true
    download_file "agent-os/standards/frontend/components.md" "agent-os/standards/frontend/components.md" || true
    download_file "agent-os/standards/frontend/css.md" "agent-os/standards/frontend/css.md" || true
    download_file "agent-os/standards/frontend/responsive.md" "agent-os/standards/frontend/responsive.md" || true

    # Global standards
    download_file "agent-os/standards/global/coding-style.md" "agent-os/standards/global/coding-style.md" || true
    download_file "agent-os/standards/global/commenting.md" "agent-os/standards/global/commenting.md" || true
    download_file "agent-os/standards/global/conventions.md" "agent-os/standards/global/conventions.md" || true
    download_file "agent-os/standards/global/error-handling.md" "agent-os/standards/global/error-handling.md" || true
    download_file "agent-os/standards/global/tech-stack.md" "agent-os/standards/global/tech-stack.md" || true
    download_file "agent-os/standards/global/validation.md" "agent-os/standards/global/validation.md" || true

    # Testing standards
    download_file "agent-os/standards/testing/test-writing.md" "agent-os/standards/testing/test-writing.md" || true

    echo ""
    print_header "Installation Complete!"
    echo ""
    print_success "Agent OS has been successfully installed in your workspace"
    echo ""
    print_info "Next steps:"
    echo "  1. Review and customize the standards in agent-os/standards/"
    echo "  2. Run the product-planner agent to initialize your product"
    echo "  3. Start building features with the agent workflow"
    echo ""
}

# Check if curl is available
if ! command -v curl &> /dev/null; then
    print_error "curl is required but not installed. Please install curl and try again."
    exit 1
fi

# Run installation
install_agent_os
