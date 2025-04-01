pip install --upgrade pip 
pip install -r ./scripts/requirements.txt

# Verification 
java --version
python --version
spark-submit --version

# Clean up to reduce image size
sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/

# Enable git
git config --global --add safe.directory /workspaces/codespace-fabric-spark
