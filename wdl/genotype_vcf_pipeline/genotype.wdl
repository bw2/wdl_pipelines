
task get_size {
    File input_vcf
    File input_vcf_gbi

    command {
        grabix size ${input_vcf} >> file_size.txt
    }

    output {
        Int vcf_size = read_int("file_size.txt")
    }

    runtime {  docker: "weisburd/wdl_pipeline_misc"  }
}


task split {
  File input_vcf
  File input_vcf_gbi    # grabix index
  Int lines_per_task
  Int input_vcf_size

  command <<<
    for i in `seq 1 ${lines_per_task} ${input_vcf_size}`; do
        echo $i >> start_at_line.txt;
    done;
  >>>

  output {
    Array[Int] array = read_lines("start_at_line.txt")
  }

  runtime {  docker: "weisburd/wdl_pipeline_misc"  }
}


task get_size_and_split {
   File input_vcf
   File input_vcf_gbi    # grabix index
   Int lines_per_task

   command <<<
       grabix size ${input_vcf} >> file_size.txt
       for i in $(seq 1 ${lines_per_task} $(grabix size ${input_vcf})); do
          echo $i >> start_at_line.txt;
       done;
   >>>

  output {
    Array[Int] array = read_lines("start_at_line.txt")
    Int vcf_size = read_int("file_size.txt")
  }

   runtime {  docker: "weisburd/wdl_pipeline_misc"  }
}

task grabix_subset {
  File input_vcf
  File input_vcf_gbi    # grabix index
  Int start_at_line
  Int end_at_line
  Int input_vcf_size

  command {
    grabix grab ${input_vcf} ${start_at_line} $((${input_vcf_size} < ${end_at_line} ? ${input_vcf_size} : ${end_at_line})) > subset.vcf
  }

  output {    File output_vcf =  "subset.vcf" }
  runtime {   docker: "weisburd/wdl_pipeline_misc"  }
}


task vt_decompose {
  File input_vcf

  command {
    vt decompose -s ${input_vcf} > decomposed.vcf
  }
  output {    File output_vcf = "decomposed.vcf"  }
  runtime {   docker: "weisburd/vt"  }
}


task vt_normalize {
  File input_vcf
  File reference_fasta

  command {
	vt normalize -r ${reference_fasta} ${input_vcf} > normalized.vcf
  }

  output {     File output_vcf = "normalized.vcf"  }
  runtime {    docker: "weisburd/vt"  }
}


task vep {
  File dbnsfp_gz
  File dbnsfp_gz_tbi
  File loftee_human_ancestor_fa_gz
  File input_vcf

  command {
  	variant_effect_predictor.pl --vcf --everything --allele_number --no_stats --cache --offline --tabix --force_overwrite \
  	   --dir ~/.vep --cache_version 83 --assembly GRCh37 \
  	   --fasta ~/.vep/homo_sapiens/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz \
  	   --plugin LoF,human_ancestor_fa:${loftee_human_ancestor_fa_gz},filter_position:0.05,min_intron_size:15  \
  	   --plugin dbNSFP,${dbnsfp_gz},Polyphen2_HVAR_pred,CADD_phred,SIFT_pred,FATHMM_pred,MutationTaster_pred,MetaSVM_pred \
  	   -i ${input_vcf} -o vep_annotated.vcf
  }

  output {    File output_vcf = "vep_annotated.vcf"  }
  runtime {   docker: "weisburd/vep_with_cache:83_GRCh37"  }
}


task run_all_steps_on_subset {
  File input_vcf
  File input_vcf_gbi    # grabix index
  Int start_at_line
  Int end_at_line
  Int input_vcf_size
  File reference_fasta
  File dbnsfp_gz
  File dbnsfp_gz_tbi
  File loftee_human_ancestor_fa_gz

  command {
    grabix grab ${input_vcf} ${start_at_line} $((${input_vcf_size} < ${end_at_line} ? ${input_vcf_size} : ${end_at_line})) | \
    vt decompose -s - | \
    vt normalize -r ${reference_fasta} - | \
    variant_effect_predictor.pl --vcf --everything --allele_number --cache --offline --tabix --force_overwrite \
      	   --dir ~/.vep --cache_version 83 --assembly GRCh37 \
      	   --fasta ~/.vep/homo_sapiens/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa \
      	   --plugin LoF,human_ancestor_fa:${loftee_human_ancestor_fa_gz},filter_position:0.05,min_intron_size:15  \
      	   --plugin dbNSFP,${dbnsfp_gz},Polyphen2_HVAR_pred,CADD_phred,SIFT_pred,FATHMM_pred,MutationTaster_pred,MetaSVM_pred \
      	   --stats_file summary.html --verbose --output_file annotated_subset.vcf.gz
  }

  output {
    File log_file =  stdout()
    File stats_file =  "summary.html"
    File output_vcf_gz =  "annotated_subset.vcf.gz"
  }
  runtime {
    docker: "weisburd/wdl_pipeline_all"
    memory: "8 GB"
    disks: "local-disk 300 SSD"
  }
}


task gather_vcf_files {
  Array[File] input_vcf_gz_files

  command <<<
    zcat ${input_vcf_gz_files[0]} | head -n 1000 | grep ^# >> combined_file.txt
    for i in ${sep=' ' input_vcf_gz_files}; do
        zcat $i | grep -v ^# >> combined_file.txt
    done;
  >>>

  output {
    #Array[String] result = read_lines(stdout())
    File combined_file_txt = "combined_file.txt"
  }

  runtime {   docker: "weisburd/wdl_pipeline_misc" }
}


task gather_txt_files {
  Array[File] input_files

  command <<<
    cat ${input_files[0]} | head -n 1000 | grep ^# >> combined_file.txt
    for i in ${sep=' ' input_files}; do
        cat $i | grep -v ^# >> combined_file.txt
    done;
  >>>

  output {
    #Array[String] result = read_lines(stdout())
    File combined_file_txt = "combined_file.txt"
  }

  runtime {   docker: "weisburd/wdl_pipeline_misc" }
}



workflow wf {
  File input_vcf
  File input_vcf_gbi

  File reference_fasta
  File dbnsfp_gz
  File dbnsfp_gz_tbi
  File loftee_human_ancestor_fa_gz

  Int lines_per_task

  #call get_size { input:  input_vcf = input_vcf, input_vcf_gbi = input_vcf_gbi }
  #call split { input:  input_vcf = input_vcf, input_vcf_gbi = input_vcf_gbi,  lines_per_task = lines_per_task, input_vcf_size = get_size.vcf_size }
  call get_size_and_split { input:  input_vcf = input_vcf, input_vcf_gbi = input_vcf_gbi, lines_per_task = lines_per_task }
  scatter (start_at_line in get_size_and_split.array) {
    call run_all_steps_on_subset { input:
        input_vcf = input_vcf,
        input_vcf_gbi = input_vcf_gbi,
        input_vcf_size = get_size_and_split.vcf_size,
        start_at_line = start_at_line,
        end_at_line = start_at_line + lines_per_task - 1,
        reference_fasta = reference_fasta,
        dbnsfp_gz = dbnsfp_gz,
        dbnsfp_gz_tbi = dbnsfp_gz_tbi,
        loftee_human_ancestor_fa_gz = loftee_human_ancestor_fa_gz
    }
    #call grabix_subset { input: input_vcf = input_vcf, input_vcf_gbi = input_vcf_gbi, input_vcf_size = get_size.vcf_size,
    #  start_at_line = start_at_line, end_at_line = start_at_line + lines_per_task - 1 }
    #call vt_decompose { input:  input_vcf = grabix_subset.output_vcf }
    #call vt_normalize { input:  input_vcf = vt_decompose.output_vcf, reference_fasta = reference_fasta }
    #call vep { input: input_vcf = vt_normalize.output_vcf, dbnsfp_gz = dbnsfp_gz, loftee_human_ancestor_fa_gz = loftee_human_ancestor_fa_gz}
  }
  call gather_vcf_files {  input: input_vcf_gz_files = run_all_steps_on_subset.output_vcf_gz  }

}

