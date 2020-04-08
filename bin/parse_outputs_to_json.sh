#!/bin/bash

runName="aaa"
sessionId="bbb"
start="ccc"

resultsDir="results/raw/"
resultsPrefix="test_set_"

###########################


#ApoplastP
analysis="apoplastp"
columns=4
cat $resultsDir""$resultsPrefix""$analysis".txt" | grep -v "^#" | awk -v col=$columns 'NF==col{print}' | \
awk -v runName="$runName" \
    -v sessionId="$sessionId" \
    -v start="$start" \
    -v analysis="$analysis" \
    '{print "\{\"runName\":\"" runName "\",\"sessionId\":\"" sessionId "\",\"start\":\"" start "\",\"geneId\":\"" $1 "\",\"analysis\":\"" analysis "\",\"data\":\{" \
            "\"prediction\":\"" $2 "\"," \
            "\"probability\":" $3 \
            "\}\}"\
    }' 2>/dev/null

###########################

#DeepLoc
analysis="deeploc"
columns=13
cat $resultsDir""$resultsPrefix""$analysis".txt" | grep -v "^#" | grep -Pv "^ID\t" | awk -v col=$columns 'NF==col{print}' | \
awk -v runName="$runName" \
    -v sessionId="$sessionId" \
    -v start="$start" \
    -v analysis="$analysis" \
    '{print "\{\"runName\":\"" runName "\",\"sessionId\":\"" sessionId "\",\"start\":\"" start "\",\"geneId\":\"" $1 "\",\"analysis\":\"" analysis "\",\"data\":\{" \
            "\"subcellular_location\":\"" $2 "\"," \
            "\"score_membrane\":" $3 "," \
            "\"score_nucleus\":" $4 "," \
            "\"score_cytoplasm\":" $5 "," \
            "\"score_extracellular\":" $6 "," \
            "\"score_mitochondrion\":" $7 "," \
            "\"score_cellmembrane\":" $8 "," \
            "\"score_endoplasmicreticulum\":" $9 "," \
            "\"score_plastid\":" $10 "," \
            "\"score_golgiapparatus\":" $11 "," \
            "\"score_lysosomevacuole\":" $12 "," \
            "\"score_peroxisome\":" $13 \
            "\}\}"\
    }' 2>/dev/null

###########################

#DeepSig
analysis="deepsig"
columns=4
cat $resultsDir""$resultsPrefix""$analysis".txt" | grep -v "^#" | grep -Pv "^ID\t" | awk -v col=$columns 'NF==col{print}' | \
awk -v runName="$runName" \
    -v sessionId="$sessionId" \
    -v start="$start" \
    -v analysis="$analysis" \
    '{print "\{\"runName\":\"" runName "\",\"sessionId\":\"" sessionId "\",\"start\":\"" start "\",\"geneId\":\"" $1 "\",\"analysis\":\"" analysis "\",\"data\":\{" \
            "\"signal_peptide_type\":\"" $2 "\"," \
            "\"signal_peptide_score\":" $3 "\"," \
            "\"signal_peptide_position\":" $4 \
            "\}\}"\
    }' 2>/dev/null

###########################

#EffectorP
analysis="effectorp1"
columns=3
cat $resultsDir""$resultsPrefix""$analysis".txt" | grep -v "^#" | grep -P "\t" | awk -v col=$columns 'NF==col{print}' | \
awk -v runName="$runName" \
    -v sessionId="$sessionId" \
    -v start="$start" \
    -v analysis="$analysis" \
    '{print "\{\"runName\":\"" runName "\",\"sessionId\":\"" sessionId "\",\"start\":\"" start "\",\"geneId\":\"" $1 "\",\"analysis\":\"" analysis "\",\"data\":\{" \
            "\"effector_prediction\":\"" $2 "\"," \
            "\"effector_probability\":" $3 \
            "\}\}"\
    }' 2>/dev/null
analysis="effectorp2"
cat $resultsDir""$resultsPrefix""$analysis".txt" | grep -v "^#" | grep -P "\t" | awk -v col=$columns 'NF==col{print}' | \
awk -v runName="$runName" \
    -v sessionId="$sessionId" \
    -v start="$start" \
    -v analysis="$analysis" \
    '{print "\{\"runName\":\"" runName "\",\"sessionId\":\"" sessionId "\",\"start\":\"" start "\",\"geneId\":\"" $1 "\",\"analysis\":\"" analysis "\",\"data\":\{" \
            "\"effector_prediction\":\"" $2 "\"," \
            "\"effector_probability\":" $3 \
            "\}\}"\
    }' 2>/dev/null

###########################



