version 1.0

#######################
## This is the workflow
#######################

workflow FilterVcf {
  input {
    File vcf_input
    String vcf_output
    Int disk_size_gb
    Int? machine_mem_gb
    String docker
  }

  call FilterVcfTask {
    input:
      vcf_input = vcf_input,
      vcf_output = vcf_output,
      disk_size_gb = disk_size_gb,
      machine_mem_gb = machine_mem_gb,
      docker = docker
  }
  output {
    File filtered_vcf = FilterVcfTask.filtered_vcf
  }
}

#######################
## Tasks
#######################

task FilterVcfTask {
  input {
    File vcf_input
    String vcf_output
    Int disk_size_gb
    Int? machine_mem_gb
    String docker
  }

  command  <<<
    set -o errexit
    set -o nounset
    set -o pipefail

    bcftools view -i '
    AF[0]>=0.00005 && 
    FILTER=="PASS" && 
    QUAL>=100 &&  
    GT!="./." && 
    CHROM!="X" && CHROM!="Y"' ~{vcf_input} | bcftools view -Oz -o ~{vcf_output}
    >>> 

  output {
    File filtered_vcf = vcf_output
  }

  runtime {
    memory: "~{machine_mem_gb}G"
    cpu: 1
    bootDiskSizeGb: 15
    disks: 'local-disk ~{disk_size_gb} HDD'
    preemptible: 0
    maxRetries: 1
    docker: docker
  }
}