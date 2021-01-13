nextflow.preview.dsl=2


if (file('sample_sheet.tsv').exists()) {

    tsvFile=file('sample_sheet.tsv')
    ch_info = extractInfo(tsvFile)
    ch_info.view()

    ch_reads = extractReads(ch_info)
    ch_reads.view()

    ch_patient = extractPatient(ch_info)
    ch_patient.view()

    ch_groupPatient = groupPatient(ch_patient)
    ch_groupPatient.view()

}
else {

    Channel
        .fromFilePairs(params.reads_dir + '/*_{1,2}.fq', size: -1)
        .mix( Channel.fromFilePairs(params.reads_dir + '/*_{1,2}.fastq', size: -1) )
        .mix( Channel.fromFilePairs(params.reads_dir + '/*_{1,2}.fq.gz', size: -1) )
        .mix( Channel.fromFilePairs(params.reads_dir + '/*_{1,2}.fastq.gz', size: -1) )
        .set{ ch_reads }
        
    ch_reads.view()

}



def extractInfo(tsvFile) {
    Channel.from(tsvFile)
            .splitCsv(sep: '\t')
            .map { row ->
                patient_id  = row[0]
                sample_id   = row[1]
                status      = row[2]
                file1       = row[3]
                file2       = row[4]

        [patient_id, sample_id, status, file1, file2]
        
     }
}


def extractReads(ch_info) {
    
    ch_info.map { row ->
                sample_id   = row[1]
                file1       = row[3]
                file2       = row[4]

        [sample_id, [file1, file2]]
     }
}

def extractPatient(ch_info) {
    
    ch_info.map { row ->
                patient_id  = row[0]
                sample_id   = row[1]
                status      = row[2]
                
        [patient_id, sample_id, status]
     }
}


def groupPatient(ch_patient) {

    ch_patient.groupTuple(by:0)

}        