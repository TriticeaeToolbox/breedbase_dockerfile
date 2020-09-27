#!/bin/bash

mkdir repos

# main code
git clone https://github.com/solgenomics/cxgn-corelibs.git repos/cxgn-corelibs
git clone https://github.com/TriticeaeToolbox/sgn.git -b t3/master repos/sgn
git clone https://github.com/solgenomics/Phenome.git repos/Phenome
git clone https://github.com/solgenomics/rPackages.git repos/rPackages
git clone https://github.com/solgenomics/biosource.git repos/biosource
git clone https://github.com/solgenomics/Cview.git repos/Cview
git clone https://github.com/solgenomics/ITAG.git repos/ITAG
git clone https://github.com/solgenomics/tomato_genome.git repos/tomato_genome
git clone https://github.com/GMOD/Chado.git repos/Chado
git clone https://github.com/GMOD/chado_tools.git repos/chado_tools
git clone https://github.com/solgenomics/bio-chado-schema.git repos/Bio-Chado-Schema
git clone https://github.com/solgenomics/sgn-devtools.git repos/sgn-devtools
git clone https://github.com/solgenomics/solGS.git repos/solGS
git clone https://github.com/solgenomics/starmachine.git repos/starmachine
git clone https://github.com/GMOD/Chado repos/Chado
git clone https://github.com/GMOD/chado_tools repos/chado_tools
git clone https://github.com/GMOD/Bio-Chado-Schema repos/Bio-Chado-Schema

# local libs
git clone https://github.com/solgenomics/perl-local-lib repos/local-lib
git clone https://github.com/solgenomics/R_libs repos/R_libs

# Mason website skins
git clone https://github.com/TriticeaeToolbox/mason.git -b triticum repos/triticum
git clone https://github.com/TriticeaeToolbox/mason.git -b avena repos/avena
git clone https://github.com/TriticeaeToolbox/mason.git -b hordeum repos/hordeum
