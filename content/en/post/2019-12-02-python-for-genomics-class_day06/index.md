---
authors:
- admin
categories: [Python]
date: "2019-12-03T00:00:00Z"
draft: false
featured: true
image:
  caption: ""
  focal_point: ""
projects: []
subtitle: Learn how to blog in Academic using Jupyter notebooks
summary: Learn how to blog in Academic using Jupyter notebooks
tags: []
title: Python for genomics day 06
---

{{% toc %}}


主要介绍了几个基础的模块,函数,以及如何创建自定义函数.

# os模块(os module)

os模块是用于路径管理,文件夹管理等的模块.

## os模块的常用命令

Function  |  Meaning
-----------|----------------------------------
`os.mkdir()` | 创建新的文件夹
`os.remove()` | 删除一个文件或者文件夹
`os.chdir()` | 更改工作路径
`os.rmdir()` | 删除一个文件夹,但是要求该文件夹必须为空
`os.getcwd()` | 获取当前工作路径
`os.listdir()` | 列出当前路径下的所有文件及文件夹


```python
import os as os
# 获取当前的工作路径
result = os.getcwd()
print(result)
```

    D:\my github\shen\content\en\post\2019-12-02-python-for-genomics-class_day06
    


```python
#列出当前路径下的所有文件和文件夹
result = os.listdir()
print(result)
```

    ['.ipynb_checkpoints', 'index.ipynb', 'Practice06-Veronica.ipynb', 'sample.txt', 'sample.txt.gz']
    

得到的结果是一个列表.


```python
#创建新的文件夹
dir_name = 'new_dir_123456'
try: 
    os.mkdir(dir_name)
except:
    print("This file already exists")

#这里再次熟悉一下异常捕捉语法
# 跟R不一样,R里面如果已有路径,并不会报错,只会给出warning
try:
    os.mkdir(dir_name)
except FileExistsError:
    print('Directory not created. Directory', dir_name, 'exists.')

```

    This file already exists
    Directory not created. Directory new_dir_123456 exists.
    

需要注意的是,如果当前路径中已经存在了要创建的文件夹,则会报错,跟R中不同,R只是会给出warning.


```python
result = os.listdir()
print(result)
```

    ['.ipynb_checkpoints', 'index.ipynb', 'new_dir_123456', 'Practice06-Veronica.ipynb', 'sample.txt', 'sample.txt.gz']
    


```python
os.chdir('new_dir_123456')
```

    None
    


```python
try:
    os.chdir(dir_name)
except FileNotFoundError:
    print('No such file or directory')
```

    D:\my github\shen\content\en\post\2019-12-02-python-for-genomics-class_day06\new_dir_123456
    No such file or directory
    


```python
result = os.getcwd()
print(result)
```

    D:\my github\shen\content\en\post\2019-12-02-python-for-genomics-class_day06\new_dir_123456
    


```python
result = os.listdir()
print(result)
```

    []
    

将一个示例数据写入到新创建的文件夹中.


```python
print('Writing test file in new_dir_123456, testing.txt')
with open('testing.txt', 'w') as TEST:
    TEST.write('testing')
```

    Writing test file in new_dir_123456, testing.txt
    


```python
result = os.listdir()
print(result)
```

    ['testing.txt']
    

删除掉新创建的实例文件数据,注意,如果没有该文件,会报错.


```python
try:
    os.remove('testing.txt')
except FileNotFoundError:
    print("No this file is found.")
```


```python
os.chdir('..')
```

    None
    

删除掉新创建的文件夹.


```python
os.rmdir('new_dir_123456')
```


```python
result = os.getcwd()
print(result)
```

    D:\my github\shen\content\en\post\2019-12-02-python-for-genomics-class_day06
    


```python
result = os.listdir()
print(result)
```

    ['.ipynb_checkpoints', 'index.ipynb', 'Practice06-Veronica.ipynb', 'sample.txt', 'sample.txt.gz']
    

# gzip & urllib模块

`gzip`模块是用来处理压缩文件的.`urllib`模块是用来处理网络文件的.


```python
# Module for URL, interacting with the web
import urllib.request
# Module for reading and writing the compressed file format, gzip
import gzip
```

## GFF/GTF格式文件

ensEMBL GFF format: 

可以参考下面连接.https://uswest.ensembl.org/info/website/upload/gff.html

每行一共有9个元素,每个元素名字如下:

SEQNAME = 0
SOURCE = 1
FEATURE = 2
START = 3
END = 4
SCORE = 5
STRAND = 6
FRAME = 7
ATTRIBUTE = 8

FTP ensEMBL downloads site: https://uswest.ensembl.org/info/data/ftp/index.html

我们将每个元素的index赋值给其代表的字符变量.


```python
SEQNAME = 0
SOURCE = 1
FEATURE = 2
START = 3
END = 4
SCORE = 5
STRAND = 6
FRAME = 7
ATTRIBUTE = 8
```

另外以各种格式叫GFF3,相对来说容易解析一些.参考下面连接:

ftp://ftp.ensembl.org/pub/release-98/gff3/homo_sapiens

举个例子


```python
GTF_URL = 'https://web.stanford.edu/class/gene211/handouts/Homo_sapiens.GRCh38.chr21-truncated.gtf.gz'
GFF3_URL = 'https://web.stanford.edu/class/gene211/handouts/Homo_sapiens.GRCh38.98.chr21-partial.gff3.gz'
```

首先读取GTF格式的数据


```python
#首先使用urllib模块将文件地址进行解析
response = urllib.request.urlopen(GTF_URL)
line_count = 0
##使用gzip模块的open函数打开文件
with gzip.open(response, 'rt') as inFile:
    for line in inFile:
        # skip file comment lines
        if line.startswith('#'):
            continue
        if line_count < 1:
            line = line.rstrip('\n').split('\t')
            print(line)
            print(len(line))
        line_count += 1
```

    ['21', 'havana', 'gene', '5011799', '5017145', '.', '+', '.', 'gene_id "ENSG00000279493"; gene_version "1"; gene_name "FP565260.4"; gene_source "havana"; gene_biotype "protein_coding";']
    9
    

只打印了一行,先来看一下这个文件的格式.每行都是一个str.然后是`\t`分割符进行分割.分割之后变为list,然后每个list有9个元素.

下面我们在比较一下GTF和GFF3格式数据的差异.

读取GFF3格式数据


```python
# Just to compare GTF and GFF3. The difference is in the ATTRIBUTE column (index 8)
response = urllib.request.urlopen(GFF3_URL)
line_count = 0
with gzip.open(response, 'rt') as inFile:
    for line in inFile:
        # skip file comment lines
        if line.startswith('#'):
            continue
        if line_count < 1:
            line = line.rstrip('\n').split('\t') 
            print(line)
            print(len(line))
        line_count += 1
```

    ['21', 'Ensembl', 'chromosome', '1', '46709983', '.', '.', '.', 'ID=chromosome:21;Alias=CM000683.2,chr21,NC_000021.9']
    9
    


```python

```


```python
response = urllib.request.urlopen(GTF_URL)
genes = {}
attribute_names = ['gene_id', 'gene_name']
with gzip.open(response, 'rt') as inFile:
    for line in inFile:
        # skip file comment lines
        if line.startswith('#'):
            continue
        # split line into columns that are separated by TAB 
        column = line.rstrip('\n').split('\t')
        # manipulate column #8, attributes
        if column[FEATURE] == 'gene':
            # starting ATTRIBUTE string
            # gene_id "ENSG00000279493"; gene_version "1"; gene_name "FP565260.4";
            # remove semi-colon from right
            # gene_id "ENSG00000279493"; gene_version "1"; gene_name "FP565260.4"            
            column[ATTRIBUTE] = column[ATTRIBUTE].rstrip(';')
            # replace semi-colon space with just semi-colon, and delete double-quotes
            # then split on semi-colon
            # ['gene_id ENSG00000279493', 'gene_version 1', 'gene_name FP565260.4']
            attribute = column[ATTRIBUTE].replace('; ', ';').replace('"', '').split(';')
            for item in attribute:
                name, value = item.split(' ')
                if name == 'gene_id':
                    gene_id = value
                if name == 'gene_name':
                    gene_name = value
                if name == 'gene_biotype':
                    gene_biotype = value
            genes[gene_name] = {'gene_id': gene_id,
                                'chromsome': int(column[SEQNAME]),
                                'start': int(column[START]),
                                'end': int(column[END]),
                                'biotype': gene_biotype
                                }
            if gene_name == 'GATD3B':
                print(genes['GATD3B'])
```

    {'gene_id': 'ENSG00000280071', 'chromsome': 21, 'start': 5079294, 'end': 5128413, 'biotype': 'protein_coding'}
    


```python
genes
```




    {'FP565260.4': {'gene_id': 'ENSG00000279493',
      'chromsome': 21,
      'start': 5011799,
      'end': 5017145,
      'biotype': 'protein_coding'},
     'FP565260.3': {'gene_id': 'ENSG00000277117',
      'chromsome': 21,
      'start': 5022493,
      'end': 5040666,
      'biotype': 'protein_coding'},
     'FP565260.5': {'gene_id': 'ENSG00000279687',
      'chromsome': 21,
      'start': 5073458,
      'end': 5087867,
      'biotype': 'lncRNA'},
     'GATD3B': {'gene_id': 'ENSG00000280071',
      'chromsome': 21,
      'start': 5079294,
      'end': 5128413,
      'biotype': 'protein_coding'},
     'FP565260.2': {'gene_id': 'ENSG00000276612',
      'chromsome': 21,
      'start': 5116343,
      'end': 5133805,
      'biotype': 'protein_coding'},
     'FP565260.1': {'gene_id': 'ENSG00000275464',
      'chromsome': 21,
      'start': 5130871,
      'end': 5154658,
      'biotype': 'protein_coding'},
     'FP565260.6': {'gene_id': 'ENSG00000280433',
      'chromsome': 21,
      'start': 5155499,
      'end': 5165472,
      'biotype': 'protein_coding'},
     'AC079801.1': {'gene_id': 'ENSG00000279669',
      'chromsome': 21,
      'start': 5232668,
      'end': 5243833,
      'biotype': 'lncRNA'},
     'LINC01670': {'gene_id': 'ENSG00000279094',
      'chromsome': 21,
      'start': 5499151,
      'end': 5502542,
      'biotype': 'lncRNA'},
     'CU633967.1': {'gene_id': 'ENSG00000274333',
      'chromsome': 21,
      'start': 5553637,
      'end': 5614880,
      'biotype': 'lncRNA'},
     'Y_RNA': {'gene_id': 'ENSG00000276902',
      'chromsome': 21,
      'start': 6365955,
      'end': 6366055,
      'biotype': 'misc_RNA'},
     'FP236315.2': {'gene_id': 'ENSG00000279186',
      'chromsome': 21,
      'start': 5703182,
      'end': 5705637,
      'biotype': 'TEC'},
     'FP236315.3': {'gene_id': 'ENSG00000279784',
      'chromsome': 21,
      'start': 5705345,
      'end': 5707160,
      'biotype': 'lncRNA'},
     'FP236315.1': {'gene_id': 'ENSG00000279064',
      'chromsome': 21,
      'start': 5707004,
      'end': 5709456,
      'biotype': 'lncRNA'},
     'CU639417.1': {'gene_id': 'ENSG00000274559',
      'chromsome': 21,
      'start': 5972924,
      'end': 5973383,
      'biotype': 'protein_coding'},
     'CU639417.3': {'gene_id': 'ENSG00000280013',
      'chromsome': 21,
      'start': 6008604,
      'end': 6008810,
      'biotype': 'processed_pseudogene'},
     'CU639417.2': {'gene_id': 'ENSG00000279769',
      'chromsome': 21,
      'start': 6034690,
      'end': 6036093,
      'biotype': 'TEC'},
     'LINC01669': {'gene_id': 'ENSG00000280191',
      'chromsome': 21,
      'start': 6060340,
      'end': 6076305,
      'biotype': 'lncRNA'},
     'CU639417.4': {'gene_id': 'ENSG00000280095',
      'chromsome': 21,
      'start': 6081193,
      'end': 6082585,
      'biotype': 'lncRNA'},
     'CU639417.5': {'gene_id': 'ENSG00000280179',
      'chromsome': 21,
      'start': 6084364,
      'end': 6091407,
      'biotype': 'lncRNA'},
     'SIK1B': {'gene_id': 'ENSG00000275993',
      'chromsome': 21,
      'start': 6111131,
      'end': 6123778,
      'biotype': 'protein_coding'},
     'CU633906.5': {'gene_id': 'ENSG00000288187',
      'chromsome': 21,
      'start': 6215291,
      'end': 6217681,
      'biotype': 'lncRNA'},
     'CU633906.1': {'gene_id': 'ENSG00000275496',
      'chromsome': 21,
      'start': 6228966,
      'end': 6267317,
      'biotype': 'lncRNA'},
     'CU633906.4': {'gene_id': 'ENSG00000280019',
      'chromsome': 21,
      'start': 6272135,
      'end': 6276532,
      'biotype': 'unprocessed_pseudogene'},
     'CU633906.3': {'gene_id': 'ENSG00000279709',
      'chromsome': 21,
      'start': 6309161,
      'end': 6312948,
      'biotype': 'unprocessed_pseudogene'},
     'CU633906.2': {'gene_id': 'ENSG00000278903',
      'chromsome': 21,
      'start': 6318434,
      'end': 6360415,
      'biotype': 'lncRNA'},
     'CBSL': {'gene_id': 'ENSG00000274276',
      'chromsome': 21,
      'start': 6444869,
      'end': 6468040,
      'biotype': 'protein_coding'},
     'U2AF1L5': {'gene_id': 'ENSG00000275895',
      'chromsome': 21,
      'start': 6484623,
      'end': 6499261,
      'biotype': 'protein_coding'}}




```python
for key in genes:
    print(key)
```

    FP565260.4
    FP565260.3
    FP565260.5
    GATD3B
    FP565260.2
    FP565260.1
    FP565260.6
    AC079801.1
    LINC01670
    CU633967.1
    Y_RNA
    FP236315.2
    FP236315.3
    FP236315.1
    CU639417.1
    CU639417.3
    CU639417.2
    LINC01669
    CU639417.4
    CU639417.5
    SIK1B
    CU633906.5
    CU633906.1
    CU633906.4
    CU633906.3
    CU633906.2
    CBSL
    U2AF1L5
    


```python
for key in genes:
    if not key.startswith('FP') and not key.startswith('CU'):
        print(key)
```

    GATD3B
    AC079801.1
    LINC01670
    Y_RNA
    LINC01669
    SIK1B
    CBSL
    U2AF1L5
    


```python
for key in genes:
    if genes[key] ['biotype'] != 'protein_coding':
        print(key, genes[key])
```

    FP565260.5 {'gene_id': 'ENSG00000279687', 'chromsome': 21, 'start': 5073458, 'end': 5087867, 'biotype': 'lncRNA'}
    AC079801.1 {'gene_id': 'ENSG00000279669', 'chromsome': 21, 'start': 5232668, 'end': 5243833, 'biotype': 'lncRNA'}
    LINC01670 {'gene_id': 'ENSG00000279094', 'chromsome': 21, 'start': 5499151, 'end': 5502542, 'biotype': 'lncRNA'}
    CU633967.1 {'gene_id': 'ENSG00000274333', 'chromsome': 21, 'start': 5553637, 'end': 5614880, 'biotype': 'lncRNA'}
    Y_RNA {'gene_id': 'ENSG00000276902', 'chromsome': 21, 'start': 6365955, 'end': 6366055, 'biotype': 'misc_RNA'}
    FP236315.2 {'gene_id': 'ENSG00000279186', 'chromsome': 21, 'start': 5703182, 'end': 5705637, 'biotype': 'TEC'}
    FP236315.3 {'gene_id': 'ENSG00000279784', 'chromsome': 21, 'start': 5705345, 'end': 5707160, 'biotype': 'lncRNA'}
    FP236315.1 {'gene_id': 'ENSG00000279064', 'chromsome': 21, 'start': 5707004, 'end': 5709456, 'biotype': 'lncRNA'}
    CU639417.3 {'gene_id': 'ENSG00000280013', 'chromsome': 21, 'start': 6008604, 'end': 6008810, 'biotype': 'processed_pseudogene'}
    CU639417.2 {'gene_id': 'ENSG00000279769', 'chromsome': 21, 'start': 6034690, 'end': 6036093, 'biotype': 'TEC'}
    LINC01669 {'gene_id': 'ENSG00000280191', 'chromsome': 21, 'start': 6060340, 'end': 6076305, 'biotype': 'lncRNA'}
    CU639417.4 {'gene_id': 'ENSG00000280095', 'chromsome': 21, 'start': 6081193, 'end': 6082585, 'biotype': 'lncRNA'}
    CU639417.5 {'gene_id': 'ENSG00000280179', 'chromsome': 21, 'start': 6084364, 'end': 6091407, 'biotype': 'lncRNA'}
    CU633906.5 {'gene_id': 'ENSG00000288187', 'chromsome': 21, 'start': 6215291, 'end': 6217681, 'biotype': 'lncRNA'}
    CU633906.1 {'gene_id': 'ENSG00000275496', 'chromsome': 21, 'start': 6228966, 'end': 6267317, 'biotype': 'lncRNA'}
    CU633906.4 {'gene_id': 'ENSG00000280019', 'chromsome': 21, 'start': 6272135, 'end': 6276532, 'biotype': 'unprocessed_pseudogene'}
    CU633906.3 {'gene_id': 'ENSG00000279709', 'chromsome': 21, 'start': 6309161, 'end': 6312948, 'biotype': 'unprocessed_pseudogene'}
    CU633906.2 {'gene_id': 'ENSG00000278903', 'chromsome': 21, 'start': 6318434, 'end': 6360415, 'biotype': 'lncRNA'}
    

# 创建函数(defining functions)

使用`def`语句进行函数创建.下面举一些例子.


```python
def f_to_c(fahrenheit):
    celsius = (float(fahrenheit) - 32) * 5 / 9
    return round(celsius, 2)
```


```python
ftemp = 110
ctemp = f_to_c(56)
ctemp
```




    13.33




```python
print('C =', f_to_c(ftemp))
```

    C = 43.33
    


```python
def roman(string):
    '''
    Returns the integer value of a string in Roman numerals
    ''' 
    dictionary = {'M':1000, 'D':500, 'C':100, 'L':50, 'X':10, 'V':5, 'I':1}
    arabic = []
    # list that holds the Roman numerals as Arabic ciphers
    for letter in string.upper():
        if letter in dictionary:
            arabic.append(dictionary[letter])

    for i in range(len(arabic) - 1):
        if arabic[i] < arabic[i+1]:
            arabic[i] *= -1 # (5,10) -> (-5,10)
    print(arabic)
    return sum(arabic)
```


```python
def seq_list_from_fastq_file(filename):
    '''
    Parse fastq file returning two lists, one of all sequences
    the other of the quality strings
    '''
    seq_list = []
    quality_list = []
    
    with open(filename) as FASTQ_INPUT:
        line_cnt = 0
        for line in FASTQ_INPUT:
            line_cnt += 1
            if line_cnt == 2:
                seq_list.append(line.rstrip('\n'))
            if line_cnt % 4 == 0:
                quality_list.append(line.rstrip('\n'))
                line_cnt = 0

    return seq_list, quality_list
```


```python
DNA_codon_table = {
#                        Second Base
#        T             C             A             G
# T
    'TTT': 'Phe', 'TCT': 'Ser', 'TAT': 'Tyr', 'TGT': 'Cys',     # TxT
    'TTC': 'Phe', 'TCC': 'Ser', 'TAC': 'Tyr', 'TGC': 'Cys',     # TxC
    'TTA': 'Leu', 'TCA': 'Ser', 'TAA': '---', 'TGA': '---',     # TxA
    'TTG': 'Leu', 'TCG': 'Ser', 'TAG': '---', 'TGG': 'Trp',     # TxG
# C
    'CTT': 'Leu', 'CCT': 'Pro', 'CAT': 'His', 'CGT': 'Arg',     # CxT
    'CTC': 'Leu', 'CCC': 'Pro', 'CAC': 'His', 'CGC': 'Arg',     # CxC
    'CTA': 'Leu', 'CCA': 'Pro', 'CAA': 'Gln', 'CGA': 'Arg',     # CxA
    'CTG': 'Leu', 'CCG': 'Pro', 'CAG': 'Gln', 'CGG': 'Arg',     # CxG
# A
    'ATT': 'Ile', 'ACT': 'Thr', 'AAT': 'Asn', 'AGT': 'Ser',     # AxT
    'ATC': 'Ile', 'ACC': 'Thr', 'AAC': 'Asn', 'AGC': 'Ser',     # AxC
    'ATA': 'Ile', 'ACA': 'Thr', 'AAA': 'Lys', 'AGA': 'Arg',     # AxA
    'ATG': 'Met', 'ACG': 'Thr', 'AAG': 'Lys', 'AGG': 'Arg',     # AxG
# G
    'GTT': 'Val', 'GCT': 'Ala', 'GAT': 'Asp', 'GGT': 'Gly',     # GxT
    'GTC': 'Val', 'GCC': 'Ala', 'GAC': 'Asp', 'GGC': 'Gly',     # GxC
    'GTA': 'Val', 'GCA': 'Ala', 'GAA': 'Glu', 'GGA': 'Gly',     # GxA
    'GTG': 'Val', 'GCG': 'Ala', 'GAG': 'Glu', 'GGG': 'Gly'      # GxG
}

dna_seq = 'ATGATATGGAGGAGGTAGCCGCGCGCCATGCGCGCTATATTTTGGTAT'
```


```python
def translate_DNA_codon(codon):
    return DNA_codon_table[codon]
```


```python
def translate(seq):
    '''Return the animo acid sequence corresponding to the DNA
    sequence seq'''
    translation = ''
    for n in range(0, len(seq) - (len(seq) % 3), 3): # every third base
        translation += translate_DNA_codon(seq[n:n+3])
    return translation
```


```python
translate(dna_seq)
```




    'MetIleTrpArgArg---ProArgAlaMetArgAlaIlePheTrpTyr'




```python
def translate_in_frame(seq, framenum):
    '''Return the translation of seq in framenum 1, 2, or 3'''
    return translate(seq[framenum-1:])
```


```python
translate_in_frame(dna_seq, 2)
```




    '---TyrGlyGlyGlySerArgAlaProCysAlaLeuTyrPheGly'




```python
def print_translation_in_frame(seq, framenum, prefix):
    '''Print the translation of seq in framenum preceded by prefix'''
    print(prefix,
          framenum,
          ' ' * framenum,
          translate_in_frame(seq, framenum),
          sep='')
```


```python
print_translation_in_frame(dna_seq, 2, 'Frame ')
```

    Frame 2  ---TyrGlyGlyGlySerArgAlaProCysAlaLeuTyrPheGly
    


```python
def print_translations(seq, prefix = ''):
    '''Print the translations of seq in all three reading frames,
    each preceded by prefix'''
    # print DNA sequence, indented to line up after prefix is added
    # to translation lines
    print('\n', ' ' * (len(prefix) + 2), seq, sep='')
    for framenum in range(1,4):
        print_translation_in_frame(seq, framenum, prefix)
```


```python
print_translations(dna_seq)
```

    
      ATGATATGGAGGAGGTAGCCGCGCGCCATGCGCGCTATATTTTGGTAT
    1 MetIleTrpArgArg---ProArgAlaMetArgAlaIlePheTrpTyr
    2  ---TyrGlyGlyGlySerArgAlaProCysAlaLeuTyrPheGly
    3   AspMetGluGluValAlaAlaArgHisAlaArgTyrIleLeuVal
    


```python
def translate_with_open_reading_frames(seq, framenum):
    '''Return the translation of seq in framenum (1, 2, or 3), with
    ---'s when not within an open reading frame; assume the read is
    not in an open frame when at the beginning of seq'''
    open = False
    translation = ""
    seqlength = len(seq) - (framenum - 1)
    for n in range(framenum-1, seqlength - (seqlength % 3), 3):
        codon = translate_DNA_codon(seq[n:n+3])
        open = (open or codon == "Met") and not (codon == "---")
        translation += codon if open else "---"
    return translation
```


```python
translate_with_open_reading_frames(dna_seq, 1)
```




    'MetIleTrpArgArg------------MetArgAlaIlePheTrpTyr'




```python
def print_translation_with_open_reading_frame(seq, framenum, prefix):
    print(prefix,
          framenum,
          ' ' * framenum,
          translate_with_open_reading_frames(seq, framenum),
          sep='')
```


```python
print_translation_with_open_reading_frame(dna_seq, 1, 'Seq ')
```

    Seq 1 MetIleTrpArgArg------------MetArgAlaIlePheTrpTyr
    


```python
def print_translations_with_open_reading_frames(seq, prefix=''):
    print('\n', ' ' * (len(prefix) + 2), seq, sep='')
    for frame in range(1,4):
        print_translation_with_open_reading_frame(seq, frame, prefix)
```


```python
print_translations_with_open_reading_frames(dna_seq)
```

    
      ATGATATGGAGGAGGTAGCCGCGCGCCATGCGCGCTATATTTTGGTAT
    1 MetIleTrpArgArg------------MetArgAlaIlePheTrpTyr
    2  ---------------------------------------------
    3   ---MetGluGluValAlaAlaArgHisAlaArgTyrIleLeuVal
    


```python
def print_translations_in_frames_in_both_directions(seq):
    print_translations(seq, '5\'->3\' ORF ')
    print_translations(seq[::-1], '3\'->5\' ORF ')
```


```python
print_translations_in_frames_in_both_directions(dna_seq)
```

    
                 ATGATATGGAGGAGGTAGCCGCGCGCCATGCGCGCTATATTTTGGTAT
    5'->3' ORF 1 MetIleTrpArgArg---ProArgAlaMetArgAlaIlePheTrpTyr
    5'->3' ORF 2  ---TyrGlyGlyGlySerArgAlaProCysAlaLeuTyrPheGly
    5'->3' ORF 3   AspMetGluGluValAlaAlaArgHisAlaArgTyrIleLeuVal
    
                 TATGGTTTTATATCGCGCGTACCGCGCGCCGATGGAGGAGGTATAGTA
    3'->5' ORF 1 TyrGlyPheIleSerArgValProArgAlaAspGlyGlyGlyIleVal
    3'->5' ORF 2  MetValLeuTyrArgAlaTyrArgAlaProMetGluGluVal---
    3'->5' ORF 3   TrpPheTyrIleAlaArgThrAlaArgArgTrpArgArgTyrSer
    


```python
def print_translations_with_open_reading_frames_in_both_directions(seq):
    print_translations_with_open_reading_frames(seq, '5\'->3\' ORF ')
    print_translations_with_open_reading_frames(seq[::-1], '3\'->5\' ORF ')
```


```python
print_translations_with_open_reading_frames_in_both_directions(dna_seq)
```

    
                 ATGATATGGAGGAGGTAGCCGCGCGCCATGCGCGCTATATTTTGGTAT
    5'->3' ORF 1 MetIleTrpArgArg------------MetArgAlaIlePheTrpTyr
    5'->3' ORF 2  ---------------------------------------------
    5'->3' ORF 3   ---MetGluGluValAlaAlaArgHisAlaArgTyrIleLeuVal
    
                 TATGGTTTTATATCGCGCGTACCGCGCGCCGATGGAGGAGGTATAGTA
    3'->5' ORF 1 ------------------------------------------------
    3'->5' ORF 2  MetValLeuTyrArgAlaTyrArgAlaProMetGluGluVal---
    3'->5' ORF 3   ---------------------------------------------
    

# map函数

`map`函数跟R中的`apply`家族有点像.

`map`函数接受两个参数,第一个参数为函数,第二个参数为一个列表,然后函数对列表中的每一个元素进行处理.然后返回长度
和输入列表相同的列表.


```python
# starting list
mylist = [1.2, 3.2, 5.4, 2.1, 0.8]
```


```python
# round all values in list to nearest int
print(list(map(round, mylist)))
```

    [1, 3, 5, 2, 1]
    


```python
# define function to square values
def sqr(x):
    return round(pow(x,2),3)
```


```python
# square each value of list
print(list(map(sqr, mylist)))
```

    [1.44, 10.24, 29.16, 4.41, 0.64]
    


```python
# mylist #2
mylist2 = ['71', '72', '73', '74']
```


```python
# convert each value in list to binary (base 2)
print(list(map(chr, map(int, mylist2))))
```

    ['G', 'H', 'I', 'J']
    

# list comprehension(列表推导表达式)

列表推导表达式可以从一个列表快速的得到另外一个列表,在很多情况下,可以替换掉比较简单的`for`循环.

<b>[</b> expression <b>for</b> item <b>in</b> list <b>if</b> conditional <b>]</b>

<code>for item in list:
    if conditional:
        expression</code>


```python
mylist = []
for x in 'spam':
    mylist.append(ord(x))
print(mylist)
```

    [115, 112, 97, 109]
    


```python
# convert a string into a list of ASCII values
[ord(x) for x in 'spam']
```




    [115, 112, 97, 109]




```python
# convert a string into a set of ASCII values
{ord(x) for x in 'spaam'}  # square to curly
```




    {97, 109, 112, 115}




```python
# convert a string into a dict of ASCII values
{x: ord(x) for x in 'spaam'}
```




    {'s': 115, 'p': 112, 'a': 97, 'm': 109}




```python
S = []
V = []
M = []
for x in range(10):
    S.append(x**2)
print('S =', S)

for i in range(13):
    V.append(2**i)
print('V =', V)

for x in S:
    if x % 2 == 0:
        M.append(x)
print('M =', M)
```

    S = [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
    V = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]
    M = [0, 4, 16, 36, 64]
    


```python
S = [x**2 for x in range(10)]
V = [2**x for x in range(13)]
M = [x for x in S if x % 2 == 0]
print('S =', S)
print('V =', V)
print('M =', M)
```

    S = [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
    V = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]
    M = [0, 4, 16, 36, 64]
    


```python
# start with a matrix, in this case represented as three lists
M = [[1, 2, 3],
     [4, 5, 6],
     [7, 8, 9]]
col2 = []
```


```python
# print out just the 2nd column
for row in M:
    col2.append(row[1])
print(col2)
```

    [2, 5, 8]
    


```python
[row[1] for row in M]
```




    [2, 5, 8]




```python
# Nested comprehensions
# tuples that are the cross products of two lists: [-1,0,1] and [-1,0,1]
mylist = []
for x in range(-1,2):
    for y in range(-1,2):
        if x == y:
            mylist.append((x,y))

print(mylist)
```

    [(-1, -1), (0, 0), (1, 1)]
    


```python
[(x, y) for x in range(-1,2) for y in range(-1,2) if x == y]
```




    [(-1, -1), (0, 0), (1, 1)]




```python
numbers = [1, 2, 3, 5, 7, 8, 11, 10, 11, 14]
doubled_odds = []
for n in numbers:
    if n % 2 == 1:
        doubled_odds.append(n * 2)
print(doubled_odds)
```

    [2, 6, 10, 14, 22, 22]
    


```python
doubled_odds = [n * 2 for n in numbers if n % 2 == 1]
print (doubled_odds)
```

    [2, 6, 10, 14, 22, 22]
    


```python
# output increasing amount of string
string = 'elephants'
[string[:c + 1] for c in range(len(string))]
```




    ['e',
     'el',
     'ele',
     'elep',
     'eleph',
     'elepha',
     'elephan',
     'elephant',
     'elephants']




```python
# generate all k-mers of 23bp for a string of nucleotides
#                1         2         3         4
#      01234567890123456789012345678901234567890
dna = 'ACTGATCGATTACGTATAGTAGAATTCTATCATATATATGG'
kmers = []
for c in range(0, len(dna) - 22):
    kmers.append(dna[c:c+23])
kmers
```




    ['ACTGATCGATTACGTATAGTAGA',
     'CTGATCGATTACGTATAGTAGAA',
     'TGATCGATTACGTATAGTAGAAT',
     'GATCGATTACGTATAGTAGAATT',
     'ATCGATTACGTATAGTAGAATTC',
     'TCGATTACGTATAGTAGAATTCT',
     'CGATTACGTATAGTAGAATTCTA',
     'GATTACGTATAGTAGAATTCTAT',
     'ATTACGTATAGTAGAATTCTATC',
     'TTACGTATAGTAGAATTCTATCA',
     'TACGTATAGTAGAATTCTATCAT',
     'ACGTATAGTAGAATTCTATCATA',
     'CGTATAGTAGAATTCTATCATAT',
     'GTATAGTAGAATTCTATCATATA',
     'TATAGTAGAATTCTATCATATAT',
     'ATAGTAGAATTCTATCATATATA',
     'TAGTAGAATTCTATCATATATAT',
     'AGTAGAATTCTATCATATATATG',
     'GTAGAATTCTATCATATATATGG']




```python
# generate all 23-mers of dna
[dna[c:c+23] for c in range(0, len(dna) - 22)]
```




    ['ACTGATCGATTACGTATAGTAGA',
     'CTGATCGATTACGTATAGTAGAA',
     'TGATCGATTACGTATAGTAGAAT',
     'GATCGATTACGTATAGTAGAATT',
     'ATCGATTACGTATAGTAGAATTC',
     'TCGATTACGTATAGTAGAATTCT',
     'CGATTACGTATAGTAGAATTCTA',
     'GATTACGTATAGTAGAATTCTAT',
     'ATTACGTATAGTAGAATTCTATC',
     'TTACGTATAGTAGAATTCTATCA',
     'TACGTATAGTAGAATTCTATCAT',
     'ACGTATAGTAGAATTCTATCATA',
     'CGTATAGTAGAATTCTATCATAT',
     'GTATAGTAGAATTCTATCATATA',
     'TATAGTAGAATTCTATCATATAT',
     'ATAGTAGAATTCTATCATATATA',
     'TAGTAGAATTCTATCATATATAT',
     'AGTAGAATTCTATCATATATATG',
     'GTAGAATTCTATCATATATATGG']



# zip函数


```python
# reverse key and value in mydict
mydict = {'A':12, 'B':25, 'C':23, 'D':14}
reversed = dict(zip(mydict.values(), mydict))
print(reversed)
```

    {12: 'A', 25: 'B', 23: 'C', 14: 'D'}
    


```python
# same as above
reversed = dict(zip(mydict.values(), mydict.keys()))
print(reversed)
```

    {12: 'A', 25: 'B', 23: 'C', 14: 'D'}
    


```python

```
