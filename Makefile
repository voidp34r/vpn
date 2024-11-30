#!/usr/bin/make -f

SCRIPT_NAME=vpn-cli.sh
INSTALL_PATH=/usr/local/bin/vpn-cli

.PHONY: install uninstall reinstall doctor help

install:
	@echo "Instalando CLI VPN..."
	@sudo cp $(SCRIPT_NAME) $(INSTALL_PATH)
	@sudo chmod +x $(INSTALL_PATH)
	@echo "CLI VPN instalada em $(INSTALL_PATH)."

uninstall:
	@echo "Removendo CLI VPN..."
	@sudo rm -f $(INSTALL_PATH)
	@echo "CLI VPN removida com sucesso."

reinstall: uninstall install

doctor:
	@$(INSTALL_PATH) doctor

help:
	@$(INSTALL_PATH) help