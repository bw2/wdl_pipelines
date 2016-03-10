task vep {
  String vep_script_path = "/root/ensembl-tools-release-83/scripts/variant_effect_predictor/variant_effect_predictor.pl"
  String vep_cache_version = "81"
  String vep_assembly = "GRCh37"
  String reference_fasta_path = "homo_sapiens/${vep_cache_version}_${vep_assembly}/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa"
  File vep_cache_dir 
  File vcf_path
  
  command {
	perl ${vep_script_path}
           --vcf --everything --allele_number --no_stats --cache --offline --tabix --dir ${vep_cache_dir} --force_overwrite --cache_version ${vep_cache_version} 
	   --assembly ${vep_assembly}
	   --fasta ${vep_cache_dir}/${reference_fasta_path}
	   --plugin LoF,human_ancestor_fa:${vep_cache_dir}/loftee_data/human_ancestor.fa.gz,filter_position:0.05,min_intron_size:15 
	   --plugin dbNSFP,${vep_cache_dir}/dbNSFP/dbNSFP.gz,Polyphen2_HVAR_pred,CADD_phred,SIFT_pred,FATHMM_pred,MutationTaster_pred,MetaSVM_pred
	   -i ${vcf_path}
  }

  output {
	File output_vcf = stdout()
  }

  runtime {
    docker: "weisburd/vep:83"
    memory: "4G"
    cpu: "3"
    zones: "US_Metro MX_Metro"
  }
}


workflow generate {
  call vep
}
