#!/bin/bash

# set repos directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPTS_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
DOCKER_DIR="$(dirname $SCRIPTS_DIR)"
REPOS_DIR="$DOCKER_DIR/repos"


echo "Preparing git repos in $REPOS_DIR..."


#
# Clone the git repos
#
clone_repos () {

  # Create repos dir
  mkdir "$REPOS_DIR"

  # main code
  git clone https://github.com/solgenomics/cxgn-corelibs.git "$REPOS_DIR"/cxgn-corelibs
  git clone https://github.com/TriticeaeToolbox/sgn.git -b t3/master "$REPOS_DIR"/sgn
  git clone https://github.com/solgenomics/Phenome.git "$REPOS_DIR"/Phenome
  git clone https://github.com/solgenomics/rPackages.git "$REPOS_DIR"/rPackages
  git clone https://github.com/solgenomics/biosource.git "$REPOS_DIR"/biosource
  git clone https://github.com/solgenomics/Cview.git "$REPOS_DIR"/Cview
  git clone https://github.com/solgenomics/ITAG.git "$REPOS_DIR"/ITAG
  git clone https://github.com/solgenomics/tomato_genome.git "$REPOS_DIR"/tomato_genome
  git clone https://github.com/solgenomics/sgn-devtools.git "$REPOS_DIR"/sgn-devtools
  git clone https://github.com/solgenomics/solGS.git "$REPOS_DIR"/solGS
  git clone https://github.com/solgenomics/starmachine.git "$REPOS_DIR"/starmachine
  git clone https://github.com/GMOD/Chado "$REPOS_DIR"/Chado
  git clone https://github.com/GMOD/chado_tools "$REPOS_DIR"/chado_tools
  git clone https://github.com/GMOD/Bio-Chado-Schema "$REPOS_DIR"/Bio-Chado-Schema
  git clone https://github.com/solgenomics/DroneImageScripts.git "$REPOS_DIR"/DroneImageScripts

  # local libs
  git clone https://github.com/solgenomics/perl-local-lib "$REPOS_DIR"/local-lib
  git clone https://github.com/solgenomics/R_libs "$REPOS_DIR"/R_libs

  # Mason website skins
  git clone https://github.com/TriticeaeToolbox/mason.git -b triticum "$REPOS_DIR"/triticum
  git clone https://github.com/TriticeaeToolbox/mason.git -b triticum-sandbox "$REPOS_DIR"/triticum_sandbox
  git clone https://github.com/TriticeaeToolbox/mason.git -b triticum-uiuc "$REPOS_DIR"/triticum_uiuc
  git clone https://github.com/TriticeaeToolbox/mason.git -b triticum-arsks "$REPOS_DIR"/triticum_arsks
  git clone https://github.com/TriticeaeToolbox/mason.git -b avena "$REPOS_DIR"/avena
  git clone https://github.com/TriticeaeToolbox/mason.git -b avena-sandbox "$REPOS_DIR"/avena_sandbox
  git clone https://github.com/TriticeaeToolbox/mason.git -b hordeum "$REPOS_DIR"/hordeum
  git clone https://github.com/TriticeaeToolbox/mason.git -b hordeum-sandbox "$REPOS_DIR"/hordeum_sandbox
  git clone https://github.com/TriticeaeToolbox/kelp.git "$REPOS_DIR"/kelp

}


#
# Update the existing repos
#
update_repos () {

  # Git pull each repo
  find "$REPOS_DIR" -maxdepth 1 -type d \( ! -name $(basename "$REPOS_DIR") \) -exec bash -c "cd '{}' && echo \"Updating '{}'...\" && git pull" \;

}




# Check for existing repos directory
# If it exists: either delete and reclone or update
# If it does not exist: clone each repo
if [ -d "$REPOS_DIR" ]; then
  read -p "Do you want to remove the existing repos? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$REPOS_DIR"
    clone_repos
  else 
    update_repos
  fi
else
  clone_repos
fi
