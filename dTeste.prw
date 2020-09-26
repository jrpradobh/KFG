#include 'protheus.ch'
#INCLUDE "aArray.CH"
#INCLUDE "JSON.CH"
#INCLUDE "FWMVCDEF.CH"

/***********************************************************
* Função para buscar os municipios do IBGE de SC
* Teste de desenvolvimento KFG Distribuidroa.
* Autor: José Rogério do Prado Júnior - 26/09/2020.
***********************************************************/

User Function dTeste()
	
	Local aFields := {}
	Local aIndex := {}
	Local aSeek := {}
	Private oBrowse
	Private cAliQry := GetNextAlias()
	Private oTempTable
	//Cria Tabela
    FTab()
    //Retorna dados do WS e carrega na tabela temporaria
    FRetWs()
    
	aAdd(aFields,{OemToAnsi("ID") 		, "TMP_ID" 	  ,"C"    ,07 	, 0	, })
	aAdd(aFields,{OemToAnsi("Municipio"), "TMP_MUN"   ,"C"	,15		, 0 , })
	aAdd(aFields,{OemToAnsi("Microreg") , "TMP_MIREG" ,"C"	,30 	, 0	, "@!"})
	aAdd(aFields,{OemToAnsi("Mesoreg")  , "TMP_MEREG" ,"C"	,30 	, 0	, "@!"})
	aAdd(aFields,{OemToAnsi("UF") 		, "TMP_UF" 	  ,"C"	,02 	, 0	, "@!"})
	aAdd(aFields,{OemToAnsi("Regiao")   , "TMP_REG"   ,"C"	,15 	, 0	, "@!"})

    //Indice
	aAdd( aIndex, "TMP_ID" )
	aAdd( aIndex, "TMP_MUN" )

    //Busca do Indice
	aAdd( aSeek, { "ID"	,{{"","C",07,0,"ID",""}},1 } )
	aAdd( aSeek, { "Municipio",{{"","C",30,0,"Municipio",}},1 } )
	
	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias(cAliQry) //Set o Alias
	oBrowse:SetQueryIndex(aIndex) //Set o indice
	oBrowse:SetTemporary(.T.) //Habilita tabela temporaria
	oBrowse:SetSeek(.T.,aSeek) //Seta a Busca do Indice
	oBrowse:SetFields(aFields) 
	oBrowse:SetUseFilter(.F.)
	oBrowse:SetDescription( "Tela Municipios" )
    //oBrowse:SetOnlyFields( {"ID" , "MUNICIPIO", "MICROREG", "MESOREG", "UF", "REGIAO"})
	oBrowse:Activate()

	(cAliQry)->(dbCloseArea())
	oTempTable:Delete() 
Return

Static Function FTab()

	Local aFields := {}
	

	//Criação do objeto
	oTempTable := FWTemporaryTable():New(cAliQry)
	
	//Monta os campos da tabela
	aadd(aFields,{"TMP_ID","C",7,0})
	aadd(aFields,{"TMP_MUN","C",15,0})
	aadd(aFields,{"TMP_MIREG","C",30,0})
	aadd(aFields,{"TMP_MEREG","C",30,0})
	aadd(aFields,{"TMP_UF","C",2,0})
	aadd(aFields,{"TMP_REG","C",15,0})
	
	oTemptable:SetFields( aFields )
		
	oTemptable:AddIndex("1", {"TMP_ID"} )
    oTemptable:AddIndex("2", {"TMP_MUN"} )

	//Criação da tabela
	oTempTable:Create()
	
Return

Static Function FRetWs()
	Local cHost := "http://servicodados.ibge.gov.br"
	Local cPath := "/api/v1/localidades/estados/sc/municipios"
	Local cHeaderGet := ""
	Local aJson := {}
	Local cJson := ""
	Local nX := 0
	//Retorno dos dados do WS
	cJson := HttpGet( cHost+cPath, , 30,  ,@cHeaderGet )
	//Converte para array de Json
	aJson := FromJson(cJson)
	//Grava os dados na tabela temporaria
	for nX := 1 to Len(aJson)	
		RECLOCK(cAliQry,.T.)
		(cAliQry)->TMP_ID  	  := cValToChar(aJson[nX][#'id'])
		(cAliQry)->TMP_MUN    := aJson[nX][#'nome']
		(cAliQry)->TMP_MIREG  := FwNoAccent(aJson[nX][#'microrregiao'][#'nome'])
	    (cAliQry)->TMP_MEREG  := FwNoAccent(aJson[nX][#'microrregiao'][#'mesorregiao'][#'nome'])
	    (cAliQry)->TMP_UF     := aJson[nX][#'microrregiao'][#'mesorregiao'][#'UF'][#'sigla']
	    (cAliQry)->TMP_REG    := FwNoAccent(aJson[nX][#'microrregiao'][#'mesorregiao'][#'UF'][#'regiao'][#'nome'])
	    (cAliQry)->(MsUnlock())
    next
 
return 

