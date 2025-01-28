version 1.0

#######################
## This is the workflow
#######################

workflow FilterVcf {
  input {
    File vcf_input
    String vcf_output
    Int disk_size_gb
    Int? machine_mem_mb
    String docker
  }

  call FilterVcfTask {
    input:
      vcf_input = vcf_input,
      vcf_output = vcf_output,
      disk_size_gb = disk_size_gb,
      machine_mem_mb = machine_mem_mb,
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
    Int? machine_mem_mb
    String docker
  }

  command  <<<
    set -o errexit
    set -o nounset
    set -o pipefail

    bcftools view -i '
      AF[0] > 0.05 && 
      INFO/SVTYPE="DEL" && 
      FILTER="PASS" && 
      (INFO/EVIDENCE ~ "RD" && (INFO/EVIDENCE ~ "SR" || INFO/EVIDENCE ~ "PE"))
    ' ~{vcf_input} -o ~{vcf_output}
    >>> 

  output {
    File filtered_vcf = vcf_output
  }

  runtime {
    memory: "~{machine_mem_mb}MiB"
    cpu: 1
    bootDiskSizeGb: 15
    disks: 'local-disk ${disk_size_gb} HDD'
    preemptible: 3
    maxRetries: 1
    docker: docker
  }
}