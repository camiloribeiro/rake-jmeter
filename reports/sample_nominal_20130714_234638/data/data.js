var project_name = "Project Rake Jmeter";
var name_resource = [["Page Example"],["Second Page"], ["Third Page"], ["Fourth Page"]];

var num_requests = [
[["request_label","Number of Requests"],["Build 312",120],["Build 313",130],["Build 314",125],["Build 315",120],["Build 316",116],["Build 317",123],["Build 318",132],["Build 319",130],["Build 320",125],["Build 321",139]],
[["request_label","Number of Requests"],["Build 42",100],["Build 43",110],["Build 44",145],["Build 45",125],["Build 46",156],["Build 47",147],["Build 48",102],["Build 49",140],["Build 320",135],["Build 321",123]],
[["request_label","Number of Requests"],["Build 542",120],["Build 543",130],["Build 544",125],["Build 545",120],["Build 546",116],["Build 547",123],["Build 548",132],["Build 549",130],["Build 320",125],["Build 321",139]],
[["request_label","Number of Requests"],["Build 62",120],["Build 63",130],["Build 64",125],["Build 65",120],["Build 66",116],["Build 67",123],["Build 68",132],["Build 69",130],["Build 320",125],["Build 321",139]]
];

var error_rate = [
[["request_label","Error Rate"],["Build 312",0],["Build 313",0],["Build 314",0],["Build 315",0],["Build 316",0],["Build 317",0],["Build 318",3],["Build 319",0],["Build 320",0],["Build 321",0]],
[["request_label","Error Rate"],["Build 42",0],["Build 43",0],["Build 44",0],["Build 45",0],["Build 46",0],["Build 47",0],["Build 48",3],["Build 49",0],["Build 320",0],["Build 321",0]],
[["request_label","Error Rate"],["Build 542",0],["Build 543",0],["Build 544",0],["Build 545",0],["Build 546",0],["Build 547",0],["Build 548",3],["Build 549",0],["Build 320",0],["Build 321",0]],
[["request_label","Error Rate"],["Build 62",3],["Build 63",0],["Build 64",5],["Build 65",0],["Build 66",3],["Build 67",0],["Build 68",0],["Build 69",0],["Build 320",2],["Build 321",0]]
];

var deviation = [
[["request_label","Std Deviation","% deviation"],["Build 312",10,18],["Build 313",15,15],["Build 314",12,30],["Build 315",25,30],["Build 316",15,18],["Build 317",23,50],["Build 318",14,15],["Build 319",12,15],["Build 320",24,35],["Build 321",22,20]],
[["request_label","Std Deviation","% deviation"],["Build 42",10,18],["Build 43",15,15],["Build 44",12,30],["Build 45",25,30],["Build 46",15,18],["Build 47",23,50],["Build 48",14,15],["Build 49",12,15],["Build 320",24,35],["Build 321",22,20]],
[["request_label","Std Deviation","% deviation"],["Build 542",10,18],["Build 543",15,15],["Build 544",12,30],["Build 545",25,30],["Build 546",15,18],["Build 547",23,50],["Build 548",14,15],["Build 549",12,15],["Build 320",24,35],["Build 321",22,20]],
[["request_label","Std Deviation","% deviation"],["Build 62",10,18],["Build 63",15,15],["Build 64",12,30],["Build 65",25,30],["Build 66",15,18],["Build 67",23,50],["Build 68",14,15],["Build 69",12,15],["Build 320",24,35],["Build 321",22,20]]
];

var percentile = [
[["request_label","% under 100 ms","% under 150 ms","% under 200 ms","% under 300 ms","% under 500 ms"],["Build 312",10,18,50,10,96],["Build 313",15,15,60,80,94],["Build 314",12,30,40,55,93],["Build 315",25,30,65,90,92],["Build 316",15,18,45,64,87],["Build 317",23,50,62,72,97],["Build 318",14,15,43,80,100],["Build 319",12,15,25,50,78],["Build 320",24,35,45,50,99],["Build 321",22,28,70,76,100]],
[["request_label","% under 100 ms","% under 150 ms","% under 200 ms","% under 300 ms","% under 500 ms"],["Build 42",10,18,50,10,96],["Build 43",15,15,60,80,94],["Build 44",12,30,40,55,93],["Build 45",25,30,65,90,92],["Build 46",15,18,45,64,87],["Build 47",23,50,62,72,97],["Build 48",14,15,43,80,100],["Build 49",12,15,25,50,78],["Build 320",24,35,45,50,99],["Build 321",22,28,70,76,100]],
[["request_label","% under 100 ms","% under 150 ms","% under 200 ms","% under 300 ms","% under 500 ms"],["Build 542",10,18,50,10,96],["Build 543",15,15,60,80,94],["Build 544",12,30,40,55,93],["Build 545",25,30,65,90,92],["Build 546",15,18,45,64,87],["Build 547",23,50,62,72,97],["Build 548",14,15,43,80,100],["Build 549",12,15,25,50,78],["Build 320",24,35,45,50,99],["Build 321",22,28,70,76,100]],
[["request_label","% under 100 ms","% under 150 ms","% under 200 ms","% under 300 ms","% under 500 ms"],["Build 62",10,18,50,10,96],["Build 63",15,15,60,80,94],["Build 64",12,30,40,55,93],["Build 65",25,30,65,90,92],["Build 66",15,18,45,64,87],["Build 67",23,50,62,72,97],["Build 68",14,15,43,80,100],["Build 69",12,15,25,50,78],["Build 320",24,35,45,50,99],["Build 321",22,28,70,76,100]]
];

var response_time = [
[["request_label","Avg Resp. Time","Median","Minimum","Percentile 99","Maximum"],["Build 312",100,50,5,240,352],["Build 313",102,70,7,210,415],["Build 314",104,60,9,230,355],["Build 315",140,10,10,240,555],["Build 316",150,60,53,210,345],["Build 317",144,70,10,220,455],["Build 318",104,80,30,230,345],["Build 319",130,90,5,240,554],["Build 320",105,70,4,240,452],["Build 321",101,76,52,250,354]],
[["request_label","Avg Resp. Time","Median","Minimum","Percentile 99","Maximum"],["Build 42",100,50,5,240,352],["Build 43",102,70,7,210,415],["Build 44",104,60,9,230,355],["Build 45",140,10,10,240,555],["Build 46",150,60,53,210,345],["Build 47",144,70,10,220,455],["Build 48",104,80,30,230,345],["Build 49",130,90,5,240,554],["Build 320",105,70,4,240,452],["Build 321",101,76,52,250,354]],
[["request_label","Avg Resp. Time","Median","Minimum","Percentile 99","Maximum"],["Build 542",100,50,5,240,352],["Build 543",102,70,7,210,415],["Build 544",104,60,9,230,355],["Build 545",140,10,10,240,555],["Build 546",150,60,53,210,345],["Build 547",144,70,10,220,455],["Build 548",104,80,30,230,345],["Build 549",130,90,5,240,554],["Build 320",105,70,4,240,452],["Build 321",101,76,52,250,354]],
[["request_label","Avg Resp. Time","Median","Minimum","Percentile 99","Maximum"],["Build 62",100,50,5,240,352],["Build 63",102,70,7,210,415],["Build 64",104,60,9,230,355],["Build 65",140,10,10,240,555],["Build 66",150,60,53,210,345],["Build 67",144,70,10,220,455],["Build 68",104,80,30,230,345],["Build 69",130,90,5,240,554],["Build 320",105,70,4,240,452],["Build 321",101,76,52,250,354]]
];

var throughput = [
[["request_label","Throughput"],["Build 312",570],["Build 313",585],["Build 314",575],["Build 315",595],["Build 316",578],["Build 317",587],["Build 318",598],["Build 319",565],["Build 320",585],["Build 321",570]],
[["request_label","Throughput"],["Build 42",570],["Build 43",585],["Build 44",575],["Build 45",595],["Build 46",578],["Build 47",587],["Build 48",598],["Build 49",565],["Build 320",585],["Build 321",570]],
[["request_label","Throughput"],["Build 542",570],["Build 543",585],["Build 544",575],["Build 545",595],["Build 546",578],["Build 547",587],["Build 548",598],["Build 549",565],["Build 320",585],["Build 321",570]],
[["request_label","Throughput"],["Build 62",570],["Build 63",585],["Build 64",575],["Build 65",595],["Build 66",578],["Build 67",587],["Build 68",598],["Build 69",565],["Build 320",585],["Build 321",570]]
];
