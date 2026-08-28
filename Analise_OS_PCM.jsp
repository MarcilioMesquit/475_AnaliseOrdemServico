<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<%-- Logomarca institucional. Lida do repositorio do servidor e embutida como data URI:
     o painel continua sendo arquivo unico e a mesma imagem serve a tela e a ficha em PDF.
     Falha de leitura nao quebra nada - o cabecalho volta para a marca textual "PCM". --%>
<%
    String logoData = "";
    java.io.InputStream logoInput = null;
    try {
        java.io.File logoFile = new java.io.File("/home/mgeweb/repositorio/impressao/logo.png");
        if (logoFile.isFile() && logoFile.length() > 0 && logoFile.length() < 3145728L) {
            logoInput = new java.io.FileInputStream(logoFile);
            java.io.ByteArrayOutputStream logoBuffer = new java.io.ByteArrayOutputStream();
            byte[] logoChunk = new byte[8192];
            int logoRead;
            while ((logoRead = logoInput.read(logoChunk)) > 0) logoBuffer.write(logoChunk, 0, logoRead);
            logoData = "data:image/png;base64," + java.util.Base64.getEncoder().encodeToString(logoBuffer.toByteArray());
        }
    } catch (Throwable ignore) {
        logoData = "";
    } finally {
        if (logoInput != null) { try { logoInput.close(); } catch (Exception ignore) {} }
    }
    request.setAttribute("logoData", logoData);
%>
<%-- Janela de carga do banco. dtIni/dtFim chegam como AAAAMMDD e sao validados como numero:
     qualquer valor fora do intervalo, invertido ou nao numerico volta ao padrao de 6 meses.
     Somente numeros validados entram no SQL. --%>
<c:set var="pIni" value="0"/>
<c:catch><c:set var="pIni" value="${param.dtIni * 1}"/></c:catch>
<c:set var="pFim" value="0"/>
<c:catch><c:set var="pFim" value="${param.dtFim * 1}"/></c:catch>
<c:if test="${pIni < 19900101 || pIni > 21001231}"><c:set var="pIni" value="0"/></c:if>
<c:if test="${pFim < 19900101 || pFim > 21001231}"><c:set var="pFim" value="0"/></c:if>
<c:if test="${pIni > 0 && pFim > 0 && pIni > pFim}"><c:set var="pIni" value="0"/><c:set var="pFim" value="0"/></c:if>
<c:set var="sqlDtIni" value="ADD_MONTHS(TRUNC(SYSDATE), -6)"/>
<c:set var="sqlDtFim" value="TRUNC(SYSDATE) + 1"/>
<c:if test="${pIni > 0}"><c:set var="sqlDtIni" value="TO_DATE('${pIni}', 'YYYYMMDD')"/></c:if>
<c:if test="${pFim > 0}"><c:set var="sqlDtFim" value="TO_DATE('${pFim}', 'YYYYMMDD') + 1"/></c:if>

<snk:query var="janelaPCM">
    SELECT TO_CHAR(${sqlDtIni}, 'YYYY-MM-DD') AS DT_INI,
           TO_CHAR(${sqlDtFim} - 1, 'YYYY-MM-DD') AS DT_FIM
      FROM DUAL
</snk:query>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PCM - Análise de Ordens de Serviço</title>
    <snk:load/>
    <style>
        :root{--navy:#0b1f33;--navy-2:#123a5d;--blue:#29b6f6;--blue-2:#0b86c6;--green:#7cb342;--green-2:#558b2f;--bg:#edf3f7;--panel:#fff;--line:#dce6ed;--muted:#607286;--text:#17283a;--soft:#f5f8fa;--orange:#e07a18;--red:#c93b3b;--violet:#7457c8;--shadow:0 9px 28px rgba(11,31,51,.08);--radius:15px}
        *{box-sizing:border-box}html,body{margin:0;min-height:100%;background:var(--bg);color:var(--text);font-family:Inter,"Segoe UI",Arial,sans-serif}button,input{font:inherit}button{cursor:pointer}[hidden]{display:none!important}button:focus-visible,input:focus-visible{outline:3px solid rgba(41,182,246,.3);outline-offset:2px}
        .app{min-height:100vh;padding:15px}.topbar{position:relative;overflow:hidden;display:flex;align-items:center;justify-content:space-between;gap:20px;padding:17px 21px;border-radius:20px;color:#fff;background:linear-gradient(112deg,var(--navy) 0%,#10456e 62%,#1475a6 100%);box-shadow:0 14px 38px rgba(11,31,51,.22)}.topbar:after{content:"";position:absolute;right:-60px;top:-95px;width:260px;height:260px;border:42px solid rgba(124,179,66,.23);border-radius:50%}.brand{position:relative;z-index:1;display:flex;align-items:center;gap:13px}.brand-mark{position:relative;overflow:hidden;display:grid;place-items:center;width:46px;height:46px;flex:0 0 auto;padding:2px;border:1px solid rgba(255,255,255,.5);border-radius:14px;background:#fff}
        .brand-mark img{position:relative;z-index:1;display:block;width:100%;height:100%;object-fit:contain}
        .brand-fallback{position:absolute;inset:0;display:grid;place-items:center;color:var(--navy);font-size:12px;font-weight:900;letter-spacing:.04em}.eyebrow{margin:0 0 3px;color:#aee1f7;font-size:9px;font-weight:900;letter-spacing:.12em;text-transform:uppercase}.topbar h1{margin:0;font-size:clamp(21px,2.4vw,32px);line-height:1.05;letter-spacing:-.035em}.topbar p{margin:5px 0 0;color:#d7ebf5;font-size:11px}.updated{position:relative;z-index:1;text-align:right}.updated span{display:block;color:#afd6e8;font-size:8px;font-weight:800;text-transform:uppercase;letter-spacing:.09em}.updated strong{display:block;margin-top:4px;font-size:14px}
        .filter-panel{position:relative;z-index:20;margin:12px 0;padding:12px;border:1px solid var(--line);border-radius:var(--radius);background:rgba(255,255,255,.98);box-shadow:var(--shadow)}.filter-grid{display:grid;grid-template-columns:minmax(210px,1.3fr) repeat(2,minmax(125px,.62fr)) repeat(4,minmax(135px,.8fr));gap:8px}.field{min-width:0}.field-label{display:block;margin:0 0 4px;color:var(--muted);font-size:8px;font-weight:900;letter-spacing:.065em;text-transform:uppercase}.control{width:100%;height:38px;padding:0 10px;border:1px solid var(--line);border-radius:9px;color:var(--text);background:#fff;font-size:10px}.search{position:relative}.search .control{padding-left:31px}.search:before{content:"";position:absolute;left:11px;bottom:12px;width:10px;height:10px;border:2px solid #7892a5;border-radius:50%}.search:after{content:"";position:absolute;left:21px;bottom:10px;width:5px;height:2px;background:#7892a5;transform:rotate(45deg)}.filter-row-extra{display:grid;grid-template-columns:repeat(5,minmax(125px,1fr)) auto auto;gap:8px;margin-top:8px}.multi{position:relative}.multi-button{display:flex;align-items:center;justify-content:space-between;gap:7px;text-align:left}.multi-button:after{content:"";width:7px;height:7px;border-right:2px solid #7690a2;border-bottom:2px solid #7690a2;transform:rotate(45deg) translateY(-2px)}.multi-caption{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.multi-menu{position:absolute;z-index:100;top:calc(100% + 5px);left:0;width:max(100%,245px);padding:7px;border:1px solid var(--line);border-radius:10px;background:#fff;box-shadow:0 16px 36px rgba(11,31,51,.2)}.multi-actions{display:flex;gap:5px;padding-bottom:6px;border-bottom:1px solid var(--line)}.mini-action{flex:1;padding:6px;border:0;border-radius:6px;color:var(--blue-2);background:#e9f6fc;font-size:8px;font-weight:900}.multi-options{max-height:220px;margin-top:6px;overflow:auto}.multi-option{display:grid;grid-template-columns:15px minmax(0,1fr) auto;align-items:center;gap:7px;width:100%;padding:6px;border:0;border-radius:6px;color:var(--muted);background:transparent;text-align:left;font-size:9px}.multi-option:hover{background:var(--soft)}.check{display:grid;place-items:center;width:14px;height:14px;border:1px solid #a8bac7;border-radius:4px}.multi-option.selected .check{border-color:var(--blue-2);background:var(--blue-2)}.multi-option.selected .check:after{content:"";width:6px;height:3px;border-left:2px solid #fff;border-bottom:2px solid #fff;transform:translateY(-1px) rotate(-45deg)}.multi-name{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.multi-count{color:#8aa0ae;font-size:8px;font-weight:800}.clear{height:38px;padding:0 13px;border:0;border-radius:9px;color:#fff;background:var(--navy-2);font-size:9px;font-weight:900}.clear:hover{background:var(--blue-2)}
        .clear.apply{border:1px solid var(--line);color:var(--navy);background:#fff}
        .clear.apply:hover{color:#fff;background:var(--blue-2)}
        .clear.apply:disabled{color:var(--muted);background:#f2f6f9;cursor:default}
        .clear.apply.pending{color:#fff;background:var(--green-2);border-color:var(--green-2)}
        .load-warning{color:#a4510c;font-weight:900}.filter-meta{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-top:9px;padding-top:8px;border-top:1px solid #edf2f5;color:var(--muted);font-size:9px}.filter-meta strong{color:var(--navy)}
        .tabs{display:flex;gap:6px;margin-bottom:12px;padding:5px;border:1px solid var(--line);border-radius:12px;background:rgba(255,255,255,.88);box-shadow:0 4px 14px rgba(11,31,51,.05);overflow:auto}.tab{display:flex;align-items:center;gap:7px;padding:8px 12px;border:0;border-radius:8px;color:var(--muted);background:transparent;font-size:9px;font-weight:900;white-space:nowrap}.tab span{display:grid;place-items:center;width:18px;height:18px;border-radius:6px;color:var(--blue-2);background:#e8f5fb;font-size:8px}.tab.active{color:#fff;background:linear-gradient(110deg,var(--navy-2),var(--blue-2));box-shadow:0 5px 14px rgba(11,134,198,.2)}.tab.active span{color:#fff;background:rgba(255,255,255,.16)}.page{display:grid;gap:12px}.kpis{display:grid;grid-template-columns:repeat(7,minmax(125px,1fr));gap:9px}.kpi{position:relative;min-height:113px;padding:13px;border:1px solid var(--line);border-radius:var(--radius);background:var(--panel);box-shadow:var(--shadow);overflow:hidden}.kpi:after{content:"";position:absolute;right:-23px;bottom:-30px;width:76px;height:76px;border-radius:50%;background:var(--tint,#e9f6fc)}.kpi-head{display:flex;align-items:center;justify-content:space-between;gap:7px}.kpi-label{color:var(--muted);font-size:8px;font-weight:900;letter-spacing:.055em;text-transform:uppercase}.kpi-dot{width:8px;height:8px;border-radius:50%;background:var(--accent,var(--blue));box-shadow:0 0 0 4px var(--tint,#e9f6fc)}.kpi strong{position:relative;z-index:1;display:block;margin-top:13px;color:var(--navy);font-size:clamp(19px,1.8vw,27px);line-height:1;letter-spacing:-.035em}.kpi small{position:relative;z-index:1;display:block;margin-top:8px;color:var(--muted);font-size:8px;line-height:1.3}.delta.good{color:var(--green-2)}.delta.bad{color:var(--red)}
        .grid-3{display:grid;grid-template-columns:1.35fr 1fr 1fr;grid-auto-rows:max-content;align-items:start;gap:12px}.grid-2{display:grid;grid-template-columns:1fr 1fr;grid-auto-rows:max-content;align-items:start;gap:12px}.panel{height:max-content!important;min-height:0!important;min-width:0;align-self:start;padding:14px;border:1px solid var(--line);border-radius:var(--radius);background:#fff;box-shadow:var(--shadow)}.executive-grid{align-items:stretch}.executive-grid>.panel{height:auto!important;align-self:stretch}.panel.wide{grid-column:span 2}.panel-head{display:flex;min-height:0;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:11px}.panel-title{margin:0;color:var(--navy);font-size:13px;font-weight:900}.panel-subtitle{margin:3px 0 0;color:var(--muted);font-size:9px;line-height:1.35}.panel-note{color:var(--muted);font-size:8px;font-weight:800}.rank-list{display:grid;gap:7px}.rank{display:grid;grid-template-columns:23px minmax(0,1fr) auto;align-items:center;gap:8px}.rank-no{display:grid;place-items:center;width:23px;height:23px;border-radius:7px;color:var(--blue-2);background:#e9f6fc;font-size:8px;font-weight:900}.rank-label{display:flex;justify-content:space-between;gap:6px;margin-bottom:4px;color:var(--text);font-size:9px;font-weight:800}.rank-label span{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.bar{height:5px;border-radius:99px;background:#edf2f5;overflow:hidden}.bar i{display:block;height:100%;min-width:2px;border-radius:inherit;background:linear-gradient(90deg,var(--green),var(--blue))}.rank-value{color:var(--navy);font-size:9px;font-weight:900;text-align:right;white-space:nowrap}.summary{display:grid;gap:7px}.summary-item{display:flex;align-items:flex-start;justify-content:space-between;gap:10px;padding:8px 9px;border-radius:9px;background:var(--soft);font-size:9px}.summary-item span{color:var(--muted)}.summary-item strong{color:var(--navy);text-align:right}.auto-summary{display:grid;height:auto!important;min-height:0!important;align-content:start;gap:7px}.insight{position:relative;padding:9px 10px 9px 29px;border-left:3px solid var(--blue);border-radius:8px;background:#f0f8fc;color:#36576c;font-size:9px;line-height:1.45}.insight:before{content:"i";position:absolute;left:10px;top:9px;display:grid;place-items:center;width:12px;height:12px;border-radius:50%;color:#fff;background:var(--blue-2);font-size:8px;font-weight:900}.method{margin:0;padding:10px 12px;border:1px solid #cfe4ee;border-radius:10px;color:#446779;background:#f0f8fc;font-size:9px;line-height:1.45}
        .trend-panel{display:flex;flex-direction:column}.trend{display:flex;width:100%;height:auto!important;min-height:190px!important;max-height:none;flex:1 1 auto;align-items:stretch;align-self:stretch;justify-content:stretch;gap:6px;padding:8px 0 0;overflow-x:auto}.month{display:grid;grid-template-rows:minmax(130px,1fr) auto auto;flex:1 1 0;gap:5px;min-width:48px;text-align:center}.month-bars{display:flex;width:100%;min-width:0;align-items:flex-end;justify-content:center;gap:5px;border-bottom:1px solid var(--line)}.month-bar{width:clamp(10px,1.15vw,16px);min-height:2px;border-radius:5px 5px 0 0;background:var(--green)}.month-bar.orders{background:var(--blue)}.month-label{color:var(--text);font-size:8px;font-weight:900}.month-value{color:var(--muted);font-size:7px}.quadrant{display:grid;height:auto!important;min-height:220px!important;max-height:none;grid-template-columns:1fr 1fr;grid-auto-rows:minmax(105px,auto);align-self:start;border:1px solid var(--line);border-radius:11px;overflow:hidden}.quad{min-width:0;padding:9px}.quad:nth-child(1),.quad:nth-child(4){background:#fff8ef}.quad:nth-child(2){background:#fff1f1}.quad:nth-child(3){background:#f3faed}.quad:nth-child(odd){border-right:1px solid var(--line)}.quad:nth-child(-n+2){border-bottom:1px solid var(--line)}.quad-title{display:block;margin-bottom:7px;color:var(--muted);font-size:7px;font-weight:900;text-transform:uppercase}.chips{display:flex;flex-wrap:wrap;gap:4px}.chip{max-width:100%;padding:4px 6px;border-radius:99px;color:var(--text);background:rgba(255,255,255,.85);font-size:7px;font-weight:800;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;box-shadow:0 1px 4px rgba(11,31,51,.08)}
        .aging{display:grid;grid-template-columns:repeat(8,minmax(105px,1fr));gap:8px}.aging-card{padding:11px;border:1px solid var(--line);border-radius:12px;background:#fff;box-shadow:var(--shadow)}.aging-card span{display:block;color:var(--muted);font-size:8px;font-weight:900;text-transform:uppercase}.aging-card strong{display:block;margin-top:7px;color:var(--navy);font-size:21px}.aging-card.alert{border-color:#f2d2ae;background:#fffaf3}.aging-card.critical{border-color:#efc2c2;background:#fff7f7}.table-panel{padding:0;overflow:visible}.table-toolbar{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:13px 14px;border-bottom:1px solid var(--line)}.table-actions{display:flex;align-items:center;gap:7px}.action{height:34px;padding:0 10px;border:1px solid var(--line);border-radius:8px;color:var(--text);background:#fff;font-size:8px;font-weight:900}.action.primary{border:0;color:#fff;background:var(--navy-2)}.table-wrap{max-height:540px;overflow:auto}.data-table{width:max-content;min-width:100%;border-collapse:separate;border-spacing:0;table-layout:fixed;font-size:9px}.data-table th{position:sticky;z-index:3;top:0;padding:10px 9px;border-bottom:1px solid #d0dce4;color:#e4f2f8;background:var(--navy-2);font-size:8px;font-weight:900;text-align:left;text-transform:uppercase;white-space:nowrap}.data-table th[data-sort]{cursor:pointer}.data-table th.num,.data-table td.num{text-align:right}.data-table td{max-width:230px;padding:9px;border-bottom:1px solid #edf2f5;color:var(--muted);vertical-align:middle;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.data-table tbody tr:hover td{background:#f1f8fb}.link{padding:0;border:0;color:var(--blue-2);background:transparent;font-size:9px;font-weight:900;text-decoration:underline;text-decoration-color:rgba(11,134,198,.28);text-underline-offset:2px}.primary-text{display:block;color:var(--text);font-weight:850}.secondary-text{display:block;margin-top:2px;color:#7c91a0;font-size:7px}.badge{display:inline-flex;align-items:center;max-width:130px;padding:3px 6px;border-radius:99px;font-size:7px;font-weight:900;overflow:hidden;text-overflow:ellipsis}.badge.green{color:#3f6f22;background:#e8f4dd}.badge.orange{color:#a4510c;background:#fff0de}.badge.red{color:#a52a2a;background:#fde7e7}.badge.blue{color:#086a9b;background:#e3f4fb}.badge.violet{color:#5840a0;background:#eee9fb}.empty{padding:30px;color:var(--muted);font-size:9px;text-align:center}.column-box{position:relative}.column-menu{position:absolute;z-index:80;right:0;top:calc(100% + 5px);width:230px;padding:8px;border:1px solid var(--line);border-radius:10px;background:#fff;box-shadow:0 15px 35px rgba(11,31,51,.2)}.column-option{display:flex;align-items:center;gap:7px;padding:5px;color:var(--muted);font-size:8px}.column-option input{accent-color:var(--blue-2)}
        .aging-card.money strong{font-size:15px}
        .table-foot{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:9px 14px;border-top:1px solid var(--line)}
        .data-table th .sort-mark{margin-left:4px;font-size:7px}
        .pareto{display:grid;gap:7px}.pareto-row{display:grid;grid-template-columns:minmax(0,1fr) 76px 50px;align-items:center;gap:8px;font-size:8px}.pareto-name{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--text);font-weight:800}.pareto-value,.pareto-pct{text-align:right;color:var(--muted);font-weight:800}.quality-button{border-color:#d8e8d0;color:var(--green-2);background:#f3faed}.quality-list{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}.quality-item{padding:10px;border:1px solid var(--line);border-radius:10px;background:var(--soft)}.quality-item span{display:block;color:var(--muted);font-size:8px}.quality-item strong{display:block;margin-top:5px;color:var(--navy);font-size:17px}
        .modal{position:fixed;z-index:1000;inset:0;display:grid;place-items:center;padding:14px;background:rgba(5,18,31,.62);backdrop-filter:blur(3px)}.dialog{width:min(1240px,calc(100vw - 28px));max-height:94vh;display:flex;flex-direction:column;border-radius:18px;background:#fff;box-shadow:0 30px 90px rgba(0,0,0,.33);overflow:hidden}.modal-head{display:flex;align-items:flex-start;justify-content:space-between;gap:15px;padding:17px 19px;color:#fff;background:linear-gradient(110deg,var(--navy),var(--blue-2))}.modal-kicker{margin:0 0 3px;color:#bde6f7;font-size:8px;font-weight:900;text-transform:uppercase;letter-spacing:.09em}.modal-title{margin:0;font-size:20px}.modal-subtitle{margin:4px 0 0;color:#d9edf5;font-size:9px}.close{position:relative;width:31px;height:31px;border:1px solid rgba(255,255,255,.25);border-radius:9px;background:rgba(255,255,255,.1)}.close:before,.close:after{content:"";position:absolute;left:8px;top:14px;width:14px;height:2px;background:#fff;transform:rotate(45deg)}.close:after{transform:rotate(-45deg)}.modal-body{padding:16px 19px;overflow:auto}.modal-kpis{display:grid;grid-template-columns:repeat(6,minmax(110px,1fr));gap:8px;margin-bottom:13px}.modal-metric{padding:9px;border-radius:9px;background:var(--soft)}.modal-metric span{display:block;color:var(--muted);font-size:7px;font-weight:900;text-transform:uppercase}.modal-metric strong{display:block;margin-top:4px;color:var(--navy);font-size:12px}.detail-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:8px}.detail{min-width:0;padding:9px;border:1px solid var(--line);border-radius:9px}.detail.full{grid-column:1/-1}.detail.span2{grid-column:span 2}.detail span{display:block;color:var(--muted);font-size:7px;font-weight:900;text-transform:uppercase}.detail strong{display:block;margin-top:4px;color:var(--text);font-size:9px;word-break:break-word}.modal-section{margin-top:13px;padding-top:12px;border-top:1px solid var(--line)}.modal-foot{display:flex;justify-content:flex-end;gap:7px;padding:11px 19px;border-top:1px solid var(--line);background:var(--soft)}body.modal-open{overflow:hidden}
        @media(max-width:1180px){.filter-grid{grid-template-columns:repeat(4,1fr)}.search{grid-column:span 2}.kpis{grid-template-columns:repeat(4,1fr)}.grid-3{grid-template-columns:1fr 1fr}.grid-3>.panel:first-child{grid-column:1/-1}.aging{grid-template-columns:repeat(4,1fr)}}
        @media(max-width:950px){.app{padding:9px}.filter-grid,.filter-row-extra{grid-template-columns:repeat(2,1fr)}.search{grid-column:1/-1}.kpis{grid-template-columns:repeat(2,1fr)}.grid-3,.grid-2{grid-template-columns:1fr}.executive-grid>.panel{height:auto!important}.panel.wide{grid-column:auto}.aging{grid-template-columns:repeat(2,1fr)}.modal-kpis,.detail-grid,.quality-list{grid-template-columns:repeat(2,1fr)}.updated{display:none}.filter-meta{align-items:flex-start;flex-direction:column}}
        @media(max-width:540px){.filter-grid,.filter-row-extra,.kpis,.aging,.modal-kpis,.detail-grid,.quality-list{grid-template-columns:1fr}.search{grid-column:auto}.brand-mark{display:none}.detail.span2{grid-column:auto}.table-toolbar{align-items:flex-start;flex-direction:column}.filter-meta{display:none}}
        @media print{@page{size:A4 portrait;margin:8mm}.filter-panel,.tabs,.table-actions,.table-foot,.modal{display:none!important}.app{padding:0}.topbar,.panel,.kpi{box-shadow:none}.page[hidden]{display:none!important}.table-wrap{max-height:none;overflow:visible}}
    </style>
    <%-- Estilo da ficha da O.S. Fica em bloco proprio porque e copiado inteiro para a aba de
         visualizacao/PDF; assim a aba nova e um documento autossuficiente. --%>
    <style id="sheetStyle">
        .sheet{--sk-dark:#0B3A6E;--sk-main:#0D4F8B;--sk-soft:#2368A2;--sk-tint:#D8E5F1;--sk-border:#D7E0E8;--sk-bg:#F7F9FB;--sk-gray:#536274;--sk-ink:#15243A;--sk-ok:#2E9D50;color:var(--sk-ink);font-family:Inter,"Segoe UI",Arial,Helvetica,sans-serif;font-size:9px;line-height:1.35;-webkit-print-color-adjust:exact;print-color-adjust:exact}
        .sheet-head{display:grid;grid-template-columns:minmax(0,1.05fr) minmax(0,1fr) auto;align-items:center;gap:14px;padding-bottom:9px;border-bottom:2px solid var(--sk-dark)}
        .sheet-brand{display:flex;align-items:center;gap:11px;min-width:0;padding-right:14px;border-right:1px solid var(--sk-border)}
        .sheet-logo{display:grid;place-items:center;width:58px;height:58px;flex:0 0 auto;overflow:hidden}
        .sheet-logo img{display:block;width:100%;height:100%;object-fit:contain}
        .sheet-company{min-width:0}
        .sheet-company strong{display:block;color:var(--sk-dark);font-size:13px;font-weight:900;letter-spacing:-.01em}
        .sheet-company span{display:block;margin-top:1px;color:var(--sk-gray);font-size:7px;font-weight:800;letter-spacing:.02em;text-transform:uppercase}
        .sheet-company em{display:block;margin-top:4px;color:var(--sk-soft);font-size:7px;font-weight:700;font-style:normal;overflow-wrap:anywhere}
        .sheet-title{min-width:0;text-align:right}
        .sheet-kicker{margin:0;color:var(--sk-gray);font-size:8px;font-weight:800}
        .sheet-title h1{margin:2px 0 0;color:var(--sk-dark);font-size:20px;font-weight:900;line-height:1.05;letter-spacing:-.02em}
        .sheet-id{min-width:78px;padding:7px 12px;border:1px solid var(--sk-tint);border-radius:8px;background:#fff;text-align:center}
        .sheet-id span{display:block;color:var(--sk-gray);font-size:7px;font-weight:800;letter-spacing:.04em;text-transform:uppercase}
        .sheet-id strong{display:block;margin-top:1px;color:var(--sk-dark);font-size:21px;font-weight:900;line-height:1.05;letter-spacing:-.02em}
        .sheet-block{margin-top:9px;break-inside:avoid;page-break-inside:avoid}
        .sheet-block.table-block{break-inside:auto;page-break-inside:auto}
        .sheet-block h2{margin:0 0 5px;color:var(--sk-dark);font-size:11px;font-weight:900;letter-spacing:.02em;text-transform:uppercase;break-after:avoid;page-break-after:avoid}
        .sheet-grid{display:grid;grid-template-columns:repeat(12,1fr);gap:5px}
        .sheet-field{grid-column:span 3;min-width:0;padding:5px 8px;border:1px solid var(--sk-border);border-radius:5px;background:#fff}
        .sheet-field.w4{grid-column:span 4}
        .sheet-field.w6{grid-column:span 6}
        .sheet-field.full{grid-column:1/-1}
        .sheet-field span{display:block;color:var(--sk-soft);font-size:7px;font-weight:800;letter-spacing:.03em;text-transform:uppercase}
        .sheet-field strong{display:block;margin-top:2px;color:var(--sk-ink);font-size:10px;font-weight:700;white-space:pre-wrap;overflow-wrap:anywhere}
        .sheet-field.accent{border-color:var(--sk-tint);background:var(--sk-bg)}
        .sheet-field.accent strong{color:var(--sk-dark);font-size:11px;font-weight:900}
        .sheet-field.ok strong:before{content:"";display:inline-block;width:6px;height:6px;margin-right:5px;border-radius:50%;background:var(--sk-ok);vertical-align:middle}
        .sheet-table{width:100%;border-collapse:collapse;table-layout:fixed;font-size:8px}
        .sheet-table thead{display:table-header-group}
        .sheet-table tfoot{display:table-row-group}
        .sheet-table tr{break-inside:avoid;page-break-inside:avoid}
        .sheet-table th{padding:5px 6px;border:1px solid var(--sk-dark);background:var(--sk-dark);color:#fff;font-size:7px;font-weight:800;letter-spacing:.03em;text-align:left;text-transform:uppercase}
        .sheet-table td{padding:4px 6px;border:1px solid var(--sk-border);color:var(--sk-ink);vertical-align:middle;overflow-wrap:anywhere}
        .sheet-table tbody tr:nth-child(even) td{background:#FBFCFD}
        .sheet-table .num{text-align:right}
        .sheet-table .mid{text-align:center}
        .sheet-table tfoot td{padding:5px 6px;border:1px solid var(--sk-tint);background:var(--sk-tint);color:var(--sk-dark);font-size:8px;font-weight:900}
        .sheet-empty{margin:0;padding:8px 10px;border:1px dashed var(--sk-border);border-radius:5px;background:var(--sk-bg);color:var(--sk-gray);font-size:8px}
        .sheet-foot{display:grid;grid-template-columns:auto minmax(0,1fr) auto;align-items:center;gap:12px;margin-top:11px;padding:8px 11px;border:1px solid var(--sk-border);border-radius:6px;background:var(--sk-bg);color:var(--sk-gray);font-size:7px}
        .sheet-stamp{display:flex;align-items:center;gap:7px;color:var(--sk-dark);font-size:9px;font-weight:900;white-space:nowrap}
        .sheet-stamp:before{content:"";width:15px;height:15px;flex:0 0 auto;border:1.5px solid var(--sk-main);border-top-width:5px;border-radius:3px}
        .sheet-doc p{margin:0;line-height:1.45}
        .sheet-tag{padding:5px 10px;border:1px solid var(--sk-border);border-radius:6px;background:#fff;color:var(--sk-dark);font-size:8px;font-weight:900;white-space:nowrap}
        @media print{
            .sheet{font-size:8px;line-height:1.22}
            .sheet-head{gap:10px;padding-bottom:6px}
            .sheet-logo{width:50px;height:50px}
            .sheet-title h1{font-size:18px}
            .sheet-id{padding:5px 10px}
            .sheet-id strong{font-size:19px}
            .sheet-block{margin-top:6px}
            .sheet-block h2{margin-bottom:3px;font-size:10px}
            .sheet-grid{gap:3px}
            .sheet-field{padding:3px 6px}
            .sheet-field strong{margin-top:1px;font-size:9px;line-height:1.18}
            .sheet-field.accent strong{font-size:10px}
            .sheet-table{font-size:7px;line-height:1.18}
            .sheet-table th{padding:3px 4px;font-size:6.5px}
            .sheet-table td{padding:2px 4px}
            .sheet-table tfoot{break-inside:avoid;page-break-inside:avoid;break-before:avoid-page;page-break-before:avoid}
            .sheet-table tfoot td{padding:3px 4px}
            .sheet-foot{break-inside:avoid;page-break-inside:avoid;margin-top:6px;padding:5px 8px}
            .sheet-stamp{font-size:8px}
        }
    </style>
</head>
<body>

<snk:query var="frotaPCM">
    SELECT
        VEI.CODVEICULO, VEI.PLACA, VEI.AD_NROFROTA AS NROFROTA,
        VEI.KMRODADODIA, VEI.KMATUAL, VEI.ANOMOD,
        NVL(MAR.DESCRICAO, 'Nao informado') AS MARCA,
        NVL(MOD.DESCRICAO, 'Nao informado') AS MODELO,
        VEI.CODCENCUS,
        NVL(CUS.DESCRCENCUS, 'Nao informado') AS CR_GERAL,
        NVL(CUS.AD_IDEXTERNO, 'Nao informado') AS SIGLACR,
        NVL(GES.NOMEUSU, 'Nao informado') AS GESTOR,
        NVL(REG.NOMEUSU, 'Nao informado') AS REGIONAL,
        NVL(TIP.DESCRICAO, 'Nao informado') AS TIPO_VEICULO,
        NVL(TIP.FROTASIGLA, 'Nao informado') AS FROTASIGLA,
        NVL(TRD.DESCRICAO, 'Nao informado') AS TIPO_RODADO,
        VEI.ATIVO AS ATIVO_CODIGO,
        VEI.CODTIPVEI,
        NVL(TVC.DESCRICAO, 'Nao informado') AS PROPRIO,
        VEI.AD_MANUTENCAO AS MANUTENCAO_CODIGO
    FROM TGFVEI VEI
        LEFT JOIN TMSMODELOVEI MOD ON MOD.CODMODELOVEI = VEI.CODMODELOVEI
        LEFT JOIN TMSMARCAVEI MAR ON MAR.CODMARCAVEI = VEI.CODMARCAVEI
        LEFT JOIN TSICUS CUS ON CUS.CODCENCUS = VEI.CODCENCUS
        LEFT JOIN TSIUSU GES ON GES.CODUSU = CUS.CODUSURESP
        LEFT JOIN TSIUSU REG ON REG.CODUSU = CUS.AD_REGIONAL
        LEFT JOIN AD_TIPCAR TIP ON TIP.CODTIPCAR = VEI.AD_CODTIPCAR
        LEFT JOIN TMSTRD TRD ON TRD.CODTIPRD = VEI.CODTIPRD
        LEFT JOIN TMSTVC TVC ON TVC.CODTIP = VEI.CODTIPVEI
    WHERE VEI.CODVEICULO <> 0
</snk:query>

<snk:query var="ordensPCM">
    WITH PARAMETROS AS (
        SELECT ${sqlDtIni} AS DT_INI, ${sqlDtFim} AS DT_FIM FROM DUAL
    )
    SELECT
        OS.NUOS, OS.CODVEICULO, VEI.PLACA, VEI.AD_NROFROTA AS NROFROTA, VEI.ANOMOD,
        NVL(MAR.DESCRICAO, 'Nao informado') AS MARCA,
        NVL(MOD.DESCRICAO, 'Nao informado') AS MODELO,
        NVL(TIP.DESCRICAO, 'Nao informado') AS TIPO_VEICULO,
        VEI.CODTIPVEI,
        NVL(TVC.DESCRICAO, 'Nao informado') AS PROPRIO,
        OS.CODCENCUS,
        NVL(CUS.DESCRCENCUS, 'Nao informado') AS CR_GERAL,
        NVL(CUS.AD_IDEXTERNO, 'Nao informado') AS SIGLACR,
        NVL(GES.NOMEUSU, 'Nao informado') AS GESTOR,
        NVL(REG.NOMEUSU, 'Nao informado') AS REGIONAL,
        OS.STATUS AS STATUS_CODIGO,
        NVL(OPTION_LABEL('TCFOSCAB', 'STATUS', OS.STATUS), 'Nao informado') AS STATUS_OS,
        NVL(OPTION_LABEL('TCFOSCAB', 'TIPO', OS.TIPO), 'Nao informado') AS TIPO_OS,
        NVL(OPTION_LABEL('TCFOSCAB', 'MANUTENCAO', OS.MANUTENCAO), 'Nao informado') AS TIPO_MANUT,
        OS.NUPLANO AS COD_PLANO, MAN.DESCRICAO AS PLANO_MANUT,
        OS.KM AS KM_OS, OS.HORIMETRO AS HORIMETRO_OS,
        REPLACE(REPLACE(REPLACE(DBMS_LOB.SUBSTR(OS.AD_OBSERV, 4000, 1), CHR(9), ' '), CHR(10), ' '), CHR(13), ' ') AS OBSERV_OS,
        OS.DTABERTURA,
        NVL(OS.DATAINI, OS.DTABERTURA) AS DATA_INICIO,
        CASE
            WHEN NVL(OS.STATUS, '-') = 'F' THEN NVL(OS.AD_DTENC, NVL(OS.DATAFIN, NVL(OS.DATAINI, OS.DTABERTURA)))
            ELSE NVL(OS.AD_DTENC, NVL(OS.DATAFIN, SYSDATE))
        END AS DATA_FIM_CALC,
        OS.AD_DTENC, OS.DATAFIN, OS.DHALTER,
        CASE WHEN NVL(OS.STATUS, '-') = 'F' THEN 0 ELSE 1 END AS OS_ABERTA
    FROM TCFOSCAB OS
        CROSS JOIN PARAMETROS P
        INNER JOIN TGFVEI VEI ON VEI.CODVEICULO = OS.CODVEICULO
        LEFT JOIN TMSMODELOVEI MOD ON MOD.CODMODELOVEI = VEI.CODMODELOVEI
        LEFT JOIN TMSMARCAVEI MAR ON MAR.CODMARCAVEI = VEI.CODMARCAVEI
        LEFT JOIN AD_TIPCAR TIP ON TIP.CODTIPCAR = VEI.AD_CODTIPCAR
        LEFT JOIN TMSTVC TVC ON TVC.CODTIP = VEI.CODTIPVEI
        LEFT JOIN TSICUS CUS ON CUS.CODCENCUS = OS.CODCENCUS
        LEFT JOIN TSIUSU GES ON GES.CODUSU = CUS.CODUSURESP
        LEFT JOIN TSIUSU REG ON REG.CODUSU = CUS.AD_REGIONAL
        LEFT JOIN TCFMAN MAN ON MAN.NUPLANO = OS.NUPLANO
    WHERE OS.CODVEICULO <> 0
      AND (OS.DATAINI IS NOT NULL OR OS.DTABERTURA IS NOT NULL)
      AND (OS.DATAINI < P.DT_FIM OR (OS.DATAINI IS NULL AND OS.DTABERTURA < P.DT_FIM))
      AND (
          OS.DATAINI >= P.DT_INI
          OR (OS.DATAINI IS NULL AND OS.DTABERTURA >= P.DT_INI)
          OR NVL(OS.STATUS, '-') <> 'F'
      )
</snk:query>

<snk:query var="itensPCM">
    WITH PARAMETROS AS (
        SELECT ${sqlDtIni} AS DT_INI, ${sqlDtFim} AS DT_FIM FROM DUAL
    ), OS_ESCOPO AS (
        SELECT OS.NUOS
        FROM TCFOSCAB OS CROSS JOIN PARAMETROS P
        WHERE OS.CODVEICULO <> 0
          AND (OS.DATAINI IS NOT NULL OR OS.DTABERTURA IS NOT NULL)
          AND (OS.DATAINI < P.DT_FIM OR (OS.DATAINI IS NULL AND OS.DTABERTURA < P.DT_FIM))
          AND (
              OS.DATAINI >= P.DT_INI
              OR (OS.DATAINI IS NULL AND OS.DTABERTURA >= P.DT_INI)
              OR NVL(OS.STATUS, '-') <> 'F'
          )
    ), ITENS AS (
        SELECT P.NUOS, P.CODPROD, P.CODNAT, P.CODLOCAL, P.CONTROLE, P.CODPARC,
               P.OBSERVACAO, NVL(P.QTDNEG, 0) AS QTD, NVL(P.VLRUNIT, 0) AS VLRUNIT,
               NVL(P.VLRTOT, NVL(P.QTDNEG, 0) * NVL(P.VLRUNIT, 0)) AS VLRTOT,
               P.SEQUENCIA, 'PRODUTO' AS TIPO_ITEM
        FROM TCFPRODOS P INNER JOIN OS_ESCOPO E ON E.NUOS = P.NUOS
        UNION ALL
        SELECT S.NUOS, S.CODPROD, S.CODNAT, NULL AS CODLOCAL, S.CONTROLE, S.CODPARC,
               S.OBSERVACAO, NVL(S.QTD, 0) AS QTD, NVL(S.VLRUNIT, 0) AS VLRUNIT,
               NVL(S.VLRTOT, NVL(S.QTD, 0) * NVL(S.VLRUNIT, 0)) AS VLRTOT,
               S.SEQUENCIA, 'SERVICO' AS TIPO_ITEM
        FROM TCFSERVOS S INNER JOIN OS_ESCOPO E ON E.NUOS = S.NUOS
    )
    SELECT
        I.NUOS, I.SEQUENCIA, I.TIPO_ITEM, I.CODPROD,
        REPLACE(REPLACE(REPLACE(NVL(PRO.DESCRPROD, 'Item sem descricao'), CHR(9), ' '), CHR(10), ' '), CHR(13), ' ') AS DESCRICAO_ITEM,
        NVL(OPTION_LABEL('TGFPRO', 'AD_CATMACRO', PRO.AD_CATMACRO), 'Nao informado') AS CAT_MACRO,
        NVL(OPTION_LABEL('TGFPRO', 'AD_CATEGORIA', PRO.AD_CATEGORIA), 'Nao informado') AS CAT_SUB,
        NVL(GRU.DESCRGRUPOPROD, 'Nao informado') AS GRUPO_PRODUTO,
        NVL(NAT.DESCRNAT, 'Nao informado') AS NATUREZA,
        NVL(LOC.DESCRLOCAL, 'Nao informado') AS LOCAL_ESTOQUE,
        I.CONTROLE,
        NVL(PAR.NOMEPARC, 'Nao informado') AS PARCEIRO,
        REPLACE(REPLACE(REPLACE(I.OBSERVACAO, CHR(9), ' '), CHR(10), ' '), CHR(13), ' ') AS OBSERVACAO_ITEM,
        I.QTD, I.VLRUNIT, I.VLRTOT
    FROM ITENS I
        LEFT JOIN TGFPRO PRO ON PRO.CODPROD = I.CODPROD
        LEFT JOIN TGFGRU GRU ON GRU.CODGRUPOPROD = PRO.CODGRUPOPROD
        LEFT JOIN TGFNAT NAT ON NAT.CODNAT = I.CODNAT
        LEFT JOIN TGFLOC LOC ON LOC.CODLOCAL = I.CODLOCAL
        LEFT JOIN TGFPAR PAR ON PAR.CODPARC = I.CODPARC
</snk:query>

<main class="app">
    <header class="topbar">
        <div class="brand"><div class="brand-mark"><span class="brand-fallback" aria-hidden="true">PCM</span><c:if test="${not empty logoData}"><img id="brandLogo" src="${logoData}" alt="MB Limpeza Urbana" onerror="this.style.display='none'"></c:if></div><div><p class="eyebrow">Planejamento e controle da manutenção</p><h1>Análise de Ordens de Serviço</h1><p>Disponibilidade, confiabilidade, custo e backlog da frota pesada</p></div></div>
        <div class="updated"><span>Atualizado em</span><strong id="updatedAt">--</strong></div>
    </header>

    <section class="filter-panel" aria-label="Filtros globais">
        <div class="filter-grid">
            <div class="field search"><label class="field-label" for="searchInput">Busca</label><input id="searchInput" class="control" type="search" placeholder="O.S., placa, frota, veículo, categoria..." autocomplete="off"></div>
            <div class="field"><label class="field-label" for="dateStart">Data inicial</label><input id="dateStart" class="control" type="date"></div>
            <div class="field"><label class="field-label" for="dateEnd">Data final</label><input id="dateEnd" class="control" type="date"></div>
            <div class="field"><span class="field-label">Regional</span><div class="multi" data-filter="regional"><button class="control multi-button" type="button"><span class="multi-caption">Todos</span></button><div class="multi-menu" hidden></div></div></div>
            <div class="field"><span class="field-label">Gestor</span><div class="multi" data-filter="manager"><button class="control multi-button" type="button"><span class="multi-caption">Todos</span></button><div class="multi-menu" hidden></div></div></div>
            <div class="field"><span class="field-label">Centro de resultado</span><div class="multi" data-filter="center"><button class="control multi-button" type="button"><span class="multi-caption">Todos</span></button><div class="multi-menu" hidden></div></div></div>
            <div class="field"><span class="field-label">Tipo de veículo</span><div class="multi" data-filter="type"><button class="control multi-button" type="button"><span class="multi-caption">Todos</span></button><div class="multi-menu" hidden></div></div></div>
        </div>
        <div class="filter-row-extra">
            <div class="field"><span class="field-label">Modelo</span><div class="multi" data-filter="model"><button class="control multi-button" type="button"><span class="multi-caption">Todos</span></button><div class="multi-menu" hidden></div></div></div>
            <div class="field"><span class="field-label">Manutenção</span><div class="multi" data-filter="maintenance"><button class="control multi-button" type="button"><span class="multi-caption">Todos</span></button><div class="multi-menu" hidden></div></div></div>
            <div class="field"><span class="field-label">Status</span><div class="multi" data-filter="status"><button class="control multi-button" type="button"><span class="multi-caption">Todos</span></button><div class="multi-menu" hidden></div></div></div>
            <div class="field"><span class="field-label">Próprio / terceiro</span><div class="multi" data-filter="ownership"><button class="control multi-button" type="button"><span class="multi-caption">Todos</span></button><div class="multi-menu" hidden></div></div></div>
            <div class="field"><span class="field-label">Faixa de idade</span><div class="multi" data-filter="ageBand"><button class="control multi-button" type="button"><span class="multi-caption">Todos</span></button><div class="multi-menu" hidden></div></div></div>
            <button id="applyPeriod" class="clear apply" type="button" disabled>Aplicar período</button><button id="clearFilters" class="clear" type="button">Limpar filtros</button>
        </div>
        <div class="filter-meta"><span id="periodText">Período: --</span><span id="loadWarning" class="load-warning" hidden></span><span id="sourceText">Fonte: carregando...</span><span><strong id="resultOrders">0</strong> O.S. - <strong id="resultFleet">0</strong> veículos</span></div>
    </section>

    <nav class="tabs" role="tablist" aria-label="Áreas do painel">
        <button class="tab active" type="button" role="tab" aria-selected="true" data-page="executive"><span>1</span>Visão executiva</button>
        <button class="tab" type="button" role="tab" aria-selected="false" data-page="pcm"><span>2</span>Torre de controle PCM</button>
        <button class="tab" type="button" role="tab" aria-selected="false" data-page="reliability"><span>3</span>Confiabilidade e falhas</button>
        <button class="tab" type="button" role="tab" aria-selected="false" data-page="costs"><span>4</span>Custos e componentes</button>
        <button class="tab" type="button" role="tab" aria-selected="false" data-page="fleet"><span>5</span>Frota / saúde do ativo</button>
        <button class="tab" type="button" role="tab" aria-selected="false" data-page="history"><span>6</span>Histórico de O.S.</button>
    </nav>

    <section id="executive" class="page" role="tabpanel">
        <div class="kpis">
            <article class="kpi" title="Estimativa baseada na sobreposição de O.S. com o período e nas horas calendário dos veículos considerados." style="--accent:#7cb342;--tint:#eaf4e1"><div class="kpi-head"><span class="kpi-label">Disponibilidade estimada</span><i class="kpi-dot"></i></div><strong id="kpiAvailability">--</strong><small id="kpiAvailabilityNote">--</small></article>
            <article class="kpi"><div class="kpi-head"><span class="kpi-label">Frota analisada</span><i class="kpi-dot"></i></div><strong id="kpiFleet">0</strong><small id="kpiFleetNote">--</small></article>
            <article class="kpi" style="--accent:#e07a18;--tint:#fff0de"><div class="kpi-head"><span class="kpi-label">Veículos com O.S. aberta</span><i class="kpi-dot"></i></div><strong id="kpiOpenVehicles">0</strong><small id="kpiOpenVehiclesNote">--</small></article>
            <article class="kpi" style="--accent:#c93b3b;--tint:#fde7e7"><div class="kpi-head"><span class="kpi-label">O.S. corretivas</span><i class="kpi-dot"></i></div><strong id="kpiCorrective">0</strong><small id="kpiCorrectiveNote">--</small></article>
            <article class="kpi" style="--accent:#7457c8;--tint:#eee9fb"><div class="kpi-head"><span class="kpi-label">% preventiva</span><i class="kpi-dot"></i></div><strong id="kpiPreventive">--</strong><small id="kpiPreventiveNote">--</small></article>
            <article class="kpi" style="--accent:#29b6f6;--tint:#e3f4fb"><div class="kpi-head"><span class="kpi-label">Custo total</span><i class="kpi-dot"></i></div><strong id="kpiCost">--</strong><small id="kpiCostNote">--</small></article>
            <article class="kpi" style="--accent:#c93b3b;--tint:#fde7e7"><div class="kpi-head"><span class="kpi-label">Backlog 7+ dias</span><i class="kpi-dot"></i></div><strong id="kpiCriticalBacklog">0</strong><small id="kpiCriticalBacklogNote">--</small></article>
        </div>
        <div class="grid-3 executive-grid">
            <article class="panel trend-panel"><div class="panel-head"><div><h2 class="panel-title">Tendência mensal</h2><p class="panel-subtitle">Custo e quantidade de O.S. no recorte carregado</p></div><span class="panel-note">Verde: custo - Azul: O.S.</span></div><div id="monthlyTrend" class="trend"></div></article>
            <article class="panel"><div class="panel-head"><div><h2 class="panel-title">Custo x indisponibilidade</h2><p class="panel-subtitle">Quadrantes pela mediana dos veículos filtrados</p></div></div><div id="quadrant" class="quadrant"></div></article>
            <article class="panel"><div class="panel-head"><div><h2 class="panel-title">Resumo executivo</h2><p class="panel-subtitle">Leitura automática e determinística</p></div></div><div id="executiveSummary" class="auto-summary"></div></article>
        </div>
        <div class="grid-3">
            <article class="panel"><div class="panel-head"><div><h2 class="panel-title">Top veículos de atenção</h2><p class="panel-subtitle">Combinação de custo, parada e recorrência</p></div></div><div id="topVehicles" class="rank-list"></div></article>
            <article class="panel"><div class="panel-head"><div><h2 class="panel-title">Top categorias</h2><p class="panel-subtitle">Categorias com maior custo</p></div></div><div id="topCategories" class="rank-list"></div></article>
            <article class="panel"><div class="panel-head"><div><h2 class="panel-title">Top CRs</h2><p class="panel-subtitle">Custo acumulado no período</p></div></div><div id="topCenters" class="rank-list"></div></article>
        </div>
        <p class="method"><strong>Metodologia:</strong> disponibilidade estimada usa horas calendário e intervalos de O.S. consolidados por veículo. Uma O.S. não comprova parada integral. Comparações anteriores são completas somente quando o período anterior está dentro da janela carregada.</p>
    </section>

    <section id="pcm" class="page" role="tabpanel" hidden>
        <div id="agingCards" class="aging"></div>
        <article class="panel table-panel"><div class="table-toolbar"><div><h2 class="panel-title">Backlog priorizado</h2><p class="panel-subtitle">Maior prioridade de acompanhamento primeiro; não representa criticidade oficial</p></div><div class="table-actions"><span id="backlogCount" class="panel-note">0 O.S.</span><button id="qualityButton" class="action quality-button" type="button">Qualidade da informação</button><div class="column-box"><button id="columnButton" class="action" type="button">Colunas</button><div id="columnMenu" class="column-menu" hidden></div></div><button id="exportBacklog" class="action primary" type="button">Exportar CSV</button></div></div><div class="table-wrap"><table id="backlogTable" class="data-table"><thead><tr>
            <th data-col="priority" data-sort="priority">Prioridade</th><th data-col="os" data-sort="os">O.S.</th><th data-col="vehicle" data-sort="fleet">Veículo</th><th data-col="plate">Placa</th><th data-col="type">Tipo</th><th data-col="center">CR</th><th data-col="regional">Regional</th><th data-col="manager">Gestor</th><th data-col="status">Status</th><th data-col="maintenance">Manutenção</th><th data-col="openDate" data-sort="start">Abertura</th><th class="num" data-col="age" data-sort="age">Dias aberta</th><th data-col="change">Última alteração</th><th class="num" data-col="stale">Dias sem alteração</th><th class="num" data-col="cost" data-sort="cost">Custo</th><th class="num" data-col="items">Itens</th><th data-col="observation">Observação</th><th class="num" data-col="km">KM</th><th data-col="plan">Plano</th>
        </tr></thead><tbody id="backlogBody"></tbody></table><div id="backlogEmpty" class="empty" hidden>Nenhuma O.S. aberta atende aos filtros.</div></div></article>
    </section>

    <section id="reliability" class="page" role="tabpanel" hidden>
        <div id="reliabilityKpis" class="kpis"></div>
        <div class="grid-3"><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Veículos por corretivas</h2><p class="panel-subtitle">Frequência no período</p></div></div><div id="correctiveVehicles" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Modelos reincidentes</h2><p class="panel-subtitle">O.S. com repetição de categoria em 90 dias</p></div></div><div id="recurrentModels" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Falhas por categoria</h2><p class="panel-subtitle">Quantidade de O.S. distintas</p></div></div><div id="failureCategories" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Tipos de veículo</h2><p class="panel-subtitle">Corretivas por tipo de ativo</p></div></div><div id="reliabilityTypes" class="rank-list"></div></article></div>
        <article class="panel table-panel"><div class="table-toolbar"><div><h2 class="panel-title">Matriz de confiabilidade por veículo</h2><p class="panel-subtitle">Recorrência: mesmo veículo + mesma categoria em nova O.S. dentro da janela</p></div><span id="reliabilityCount" class="panel-note">0 veículos</span></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Veículo</th><th class="num">Corretivas</th><th class="num">Preventivas</th><th class="num">Socorros</th><th class="num">Dias desde última O.S.</th><th class="num">Custo</th><th class="num">Parada</th><th class="num">MTTR estimado</th><th class="num">Reincidências 90d</th></tr></thead><tbody id="reliabilityBody"></tbody></table></div></article>
        <p class="method"><strong>Regra de reincidência:</strong> veículo e categoria iguais em O.S. diferentes iniciadas em até 30, 60 ou 90 dias. A categoria usa a sub-categoria; quando ausente, a categoria ou o grupo. MTTR estimado considera corretivas finalizadas.</p>
    </section>

    <section id="costs" class="page" role="tabpanel" hidden>
        <div id="costKpis" class="kpis"></div>
        <div class="grid-3"><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Custo por Regional</h2></div></div><div id="costRegional" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Custo por Gestor</h2></div></div><div id="costManager" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Custo por manutenção</h2></div></div><div id="costMaintenance" class="rank-list"></div></article></div>
        <div class="grid-3"><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Custo por CR</h2></div></div><div id="costCenters" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Custo por tipo de veículo</h2></div></div><div id="costTypes" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Custo por idade da frota</h2></div></div><div id="costAges" class="rank-list"></div></article></div>
        <div class="grid-3"><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Custo por categoria</h2></div></div><div id="costMacro" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Custo por sub-categoria</h2></div></div><div id="costSub" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Custo por grupo</h2></div></div><div id="costGroup" class="rank-list"></div></article></div>
        <div class="grid-2"><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Pareto de veículos</h2><p class="panel-subtitle">Acumulado até ultrapassar 80% do custo</p></div></div><div id="paretoVehicles" class="pareto"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Pareto de categorias</h2><p class="panel-subtitle">Sub-categoria, categoria ou grupo disponível</p></div></div><div id="paretoCategories" class="pareto"></div></article></div>
        <div class="grid-3"><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Itens mais caros</h2></div></div><div id="expensiveItems" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Itens mais consumidos</h2></div></div><div id="consumedItems" class="rank-list"></div></article><article class="panel"><div class="panel-head"><div><h2 class="panel-title">Modelos de maior custo</h2></div></div><div id="costModels" class="rank-list"></div></article></div>
    </section>

    <section id="fleet" class="page" role="tabpanel" hidden>
        <article class="panel table-panel"><div class="table-toolbar"><div><h2 class="panel-title">Saúde gerencial da frota</h2><p class="panel-subtitle">Clique no veículo para abrir o popup gerencial</p></div><span id="fleetTableCount" class="panel-note">0 veículos</span></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Veículo</th><th>Tipo / modelo</th><th>Ano / idade</th><th>CR / Regional / Gestor</th><th>Próprio</th><th class="num">KM atual</th><th class="num">O.S.</th><th class="num">Corretivas</th><th class="num">Preventivas</th><th class="num">Socorros</th><th class="num">Custo</th><th class="num">Parada</th><th class="num">Disponibilidade estimada</th><th class="num">MTTR estimado</th><th class="num">O.S. aberta</th><th class="num">Idade backlog</th><th>Atenção do ativo</th></tr></thead><tbody id="fleetBody"></tbody></table><div id="fleetEmpty" class="empty" hidden>Nenhum veículo atende aos filtros.</div></div></article>
        <p class="method"><strong>Indicador de atenção do ativo:</strong> sinal visual calculado por custo, recorrência, indisponibilidade e backlog. Não representa saúde oficial nem substitui inspeção técnica.</p>
    </section>
    <section id="history" class="page" role="tabpanel" hidden>
        <div id="historyCards" class="aging"></div>
        <article class="panel table-panel"><div class="table-toolbar"><div><h2 class="panel-title">Histórico de O.S.</h2><p class="panel-subtitle">Todas as O.S. do período filtrado, sem recorte de frota ativa ou de manutenção</p></div><div class="table-actions"><span id="historyCount" class="panel-note">0 O.S.</span><div class="column-box"><button id="historyColumnButton" class="action" type="button">Colunas</button><div id="historyColumnMenu" class="column-menu" hidden></div></div><button id="exportHistoryCsv" class="action" type="button">CSV</button><button id="exportHistoryPdf" class="action" type="button">Exportar PDF</button><button id="exportHistoryXlsx" class="action primary" type="button">Exportar XLSX</button></div></div><div class="table-wrap"><table id="historyTable" class="data-table"><thead><tr id="historyHead"></tr></thead><tbody id="historyBody"></tbody></table><div id="historyEmpty" class="empty" hidden>Nenhuma O.S. atende aos filtros no período.</div></div><div class="table-foot"><span id="historyShown" class="panel-note">--</span><button id="historyMore" class="action" type="button" hidden>Carregar mais</button></div></article>
        <p class="method"><strong>Recorte:</strong> esta aba lista todas as O.S. iniciadas dentro do período filtrado, abertas e encerradas, inclusive as de veículos inativos ou fora do escopo de manutenção - por isso a contagem pode ser maior que a das demais abas, que analisam apenas a frota ativa em manutenção. Os demais filtros do painel continuam valendo. O backlog da Torre de controle PCM segue mostrando as O.S. em aberto hoje, inclusive as iniciadas antes do período.</p>
    </section>
</main>

<textarea id="windowData" hidden><c:forEach items="${janelaPCM.rows}" var="r"><c:out value="${r.DT_INI}"/>	<c:out value="${r.DT_FIM}"/></c:forEach></textarea>
<textarea id="fleetData" hidden><c:forEach items="${frotaPCM.rows}" var="r"><c:out value="${r.CODVEICULO}"/>	<c:out value="${r.PLACA}"/>	<c:out value="${r.NROFROTA}"/>	<c:out value="${r.KMRODADODIA}"/>	<c:out value="${r.KMATUAL}"/>	<c:out value="${r.ANOMOD}"/>	<c:out value="${r.MARCA}"/>	<c:out value="${r.MODELO}"/>	<c:out value="${r.CODCENCUS}"/>	<c:out value="${r.CR_GERAL}"/>	<c:out value="${r.SIGLACR}"/>	<c:out value="${r.GESTOR}"/>	<c:out value="${r.REGIONAL}"/>	<c:out value="${r.TIPO_VEICULO}"/>	<c:out value="${r.FROTASIGLA}"/>	<c:out value="${r.TIPO_RODADO}"/>	<c:out value="${r.ATIVO_CODIGO}"/>	<c:out value="${r.CODTIPVEI}"/>	<c:out value="${r.PROPRIO}"/>	<c:out value="${r.MANUTENCAO_CODIGO}"/>
</c:forEach></textarea>
<textarea id="orderData" hidden><c:forEach items="${ordensPCM.rows}" var="r"><c:out value="${r.NUOS}"/>	<c:out value="${r.CODVEICULO}"/>	<c:out value="${r.PLACA}"/>	<c:out value="${r.NROFROTA}"/>	<c:out value="${r.ANOMOD}"/>	<c:out value="${r.MARCA}"/>	<c:out value="${r.MODELO}"/>	<c:out value="${r.TIPO_VEICULO}"/>	<c:out value="${r.CODTIPVEI}"/>	<c:out value="${r.PROPRIO}"/>	<c:out value="${r.CODCENCUS}"/>	<c:out value="${r.CR_GERAL}"/>	<c:out value="${r.SIGLACR}"/>	<c:out value="${r.GESTOR}"/>	<c:out value="${r.REGIONAL}"/>	<c:out value="${r.STATUS_CODIGO}"/>	<c:out value="${r.STATUS_OS}"/>	<c:out value="${r.TIPO_OS}"/>	<c:out value="${r.TIPO_MANUT}"/>	<c:out value="${r.COD_PLANO}"/>	<c:out value="${r.PLANO_MANUT}"/>	<c:out value="${r.KM_OS}"/>	<c:out value="${r.HORIMETRO_OS}"/>	<c:out value="${r.OBSERV_OS}"/>	<c:out value="${r.DTABERTURA}"/>	<c:out value="${r.DATA_INICIO}"/>	<c:out value="${r.DATA_FIM_CALC}"/>	<c:out value="${r.AD_DTENC}"/>	<c:out value="${r.DATAFIN}"/>	<c:out value="${r.DHALTER}"/>	<c:out value="${r.OS_ABERTA}"/>
</c:forEach></textarea>
<textarea id="itemData" hidden><c:forEach items="${itensPCM.rows}" var="r"><c:out value="${r.NUOS}"/>	<c:out value="${r.SEQUENCIA}"/>	<c:out value="${r.TIPO_ITEM}"/>	<c:out value="${r.CODPROD}"/>	<c:out value="${r.DESCRICAO_ITEM}"/>	<c:out value="${r.CAT_MACRO}"/>	<c:out value="${r.CAT_SUB}"/>	<c:out value="${r.GRUPO_PRODUTO}"/>	<c:out value="${r.NATUREZA}"/>	<c:out value="${r.LOCAL_ESTOQUE}"/>	<c:out value="${r.CONTROLE}"/>	<c:out value="${r.PARCEIRO}"/>	<c:out value="${r.OBSERVACAO_ITEM}"/>	<c:out value="${r.QTD}"/>	<c:out value="${r.VLRUNIT}"/>	<c:out value="${r.VLRTOT}"/>
</c:forEach></textarea>

<div id="mainModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="modalTitle" hidden><section class="dialog"><header class="modal-head"><div><p id="modalKicker" class="modal-kicker">Detalhes</p><h2 id="modalTitle" class="modal-title">--</h2><p id="modalSubtitle" class="modal-subtitle">--</p></div><button id="modalClose" class="close" type="button" aria-label="Fechar"></button></header><div id="modalBody" class="modal-body"></div><footer class="modal-foot"><button id="modalSecondary" class="action" type="button" hidden>Abrir cadastro do veículo</button><button id="modalPdf" class="action" type="button" hidden>Visualizar / PDF</button><button id="modalPrimary" class="action primary" type="button" hidden>Abrir O.S. no Sankhya</button><button id="modalFooterClose" class="action" type="button">Fechar</button></footer></section></div>

<script>
(function(){
    'use strict';
    var HOUR=3600000,DAY=86400000;
    var OS_APP='br.com.sankhya.soplogistica.mov.ordem.servicos';
    var VEHICLE_APP='br.com.sankhya.core.cad.veiculos';
    function id(value){return document.getElementById(value)}
    function txt(value){return String(value===null||value===undefined?'':value).trim()}
    function cleanSourceText(value){var result=txt(value).replace(/\uFFFD/g,'').replace(/\?/g,'').replace(/\s{2,}/g,' ').trim();return /^(null|undefined)$/i.test(result)?'':result}
    function num(value){var raw=txt(value).replace(/\s/g,'');if(raw.indexOf(',')>=0&&raw.indexOf('.')>=0)raw=raw.replace(/\./g,'').replace(',','.');else raw=raw.replace(',','.');var parsed=Number(raw);return Number.isFinite(parsed)?parsed:0}
    function norm(value){var result=txt(value).toLowerCase();return typeof result.normalize==='function'?result.normalize('NFD').replace(/[\u0300-\u036f]/g,''):result}
    function esc(value){return txt(value).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#039;')}
    function parseDate(value){var raw=txt(value),m;if(!raw)return null;m=raw.match(/^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2}):(\d{2})(?::(\d{2}))?)?/);if(m)return new Date(+m[1],+m[2]-1,+m[3],+(m[4]||0),+(m[5]||0),+(m[6]||0));m=raw.match(/^(\d{2})\/(\d{2})\/(\d{4})(?:\s+(\d{2}):(\d{2})(?::(\d{2}))?)?/);if(m)return new Date(+m[3],+m[2]-1,+m[1],+(m[4]||0),+(m[5]||0),+(m[6]||0));var d=new Date(raw);return Number.isNaN(d.getTime())?null:d}
    function dateInput(date){return date.getFullYear()+'-'+String(date.getMonth()+1).padStart(2,'0')+'-'+String(date.getDate()).padStart(2,'0')}
    function fmtDate(date){return date?date.toLocaleDateString('pt-BR'):'--'}
    function fmtDateTime(date){return date?date.toLocaleString('pt-BR',{day:'2-digit',month:'2-digit',year:'numeric',hour:'2-digit',minute:'2-digit'}):'--'}
    function fmtNumber(value,digits){return num(value).toLocaleString('pt-BR',{minimumFractionDigits:digits||0,maximumFractionDigits:digits||0})}
    function fmtCurrency(value,compact){var amount=num(value);return compact?'R$ '+Math.round(amount).toLocaleString('pt-BR'):amount.toLocaleString('pt-BR',{style:'currency',currency:'BRL',minimumFractionDigits:2,maximumFractionDigits:2})}
    function fmtPercent(value){return num(value).toLocaleString('pt-BR',{minimumFractionDigits:1,maximumFractionDigits:1})+'%'}
    function fmtHours(value){var minutes=Math.max(0,Math.round(num(value)*60));if(!minutes)return'0 min';if(minutes<1)return'< 1 min';var days=Math.floor(minutes/1440),hours=Math.floor((minutes%1440)/60),mins=minutes%60,parts=[];if(days)parts.push(fmtNumber(days)+' d');if(hours)parts.push(fmtNumber(hours)+' h');if(mins)parts.push(fmtNumber(mins)+' min');return parts.join(' ')}
    function valueOrInfo(value){return txt(value)||'Não informado'}
    function readRows(sourceId,columns){var raw=id(sourceId).value.replace(/^\s+|\s+$/g,'');if(!raw)return[];return raw.split(/\r?\n/).filter(function(line){return txt(line)}).map(function(line){var parts=line.split('\t'),row={};columns.forEach(function(column,index){row[column]=parts[index]===undefined?'':cleanSourceText(parts[index])});return row})}
    function sum(rows,key){return rows.reduce(function(total,row){return total+num(typeof key==='function'?key(row):row[key])},0)}
    function median(values){var sorted=values.filter(Number.isFinite).slice().sort(function(a,b){return a-b}),middle=Math.floor(sorted.length/2);return !sorted.length?0:sorted.length%2?sorted[middle]:(sorted[middle-1]+sorted[middle])/2}
    function group(rows,keyFn){var map=new Map();rows.forEach(function(row){var key=valueOrInfo(keyFn(row));if(!map.has(key))map.set(key,[]);map.get(key).push(row)});return map}
    function unique(values){return Array.from(new Set(values.filter(function(v){return txt(v)}))).sort(function(a,b){return txt(a).localeCompare(txt(b),'pt-BR',{numeric:true})})}
    function daysBetween(a,b){return a&&b?Math.max(0,(b-a)/DAY):0}
    function isOpen(row){return row.openFlag===1||row.statusCode!=='F'}
    function isCorrective(row){return norm(row.maintenance).indexOf('corret')>=0}
    function isPreventive(row){return norm(row.maintenance).indexOf('prevent')>=0}
    function isRescue(row){return norm(row.maintenance+' '+row.orderType).indexOf('socorro')>=0}
    function isReturn(row){return norm(row.maintenance+' '+row.orderType).indexOf('retorno')>=0}
    function isReopened(row){return norm(row.status).indexOf('reab')>=0}
    function vehicleName(row){return [txt(row.fleet)&&'Frota '+txt(row.fleet),txt(row.plate)].filter(Boolean).join(' - ')||'Veículo '+row.vehicleCode}
    function centerName(row){return [txt(row.centerAcronym),txt(row.center)].filter(Boolean).join(' - ')||'Não informado'}
    function ageBand(year){var age=year?new Date().getFullYear()-year:null;if(age===null||age<0||age>80)return'Não informado';if(age<=1)return'0-1 ano';if(age<=3)return'2-3 anos';if(age<=5)return'4-5 anos';if(age<=10)return'6-10 anos';return'11+ anos'}

    var fleet=readRows('fleetData',['vehicleCode','plate','fleet','kmDay','kmCurrent','year','brand','model','centerCode','center','centerAcronym','manager','regional','type','fleetType','roadType','activeCode','ownershipCode','ownership','maintenanceCode']).map(function(row){row.kmDay=num(row.kmDay);row.kmCurrent=num(row.kmCurrent);row.year=num(row.year);row.age=row.year?new Date().getFullYear()-row.year:null;row.ageBand=ageBand(row.year);return row});
    var orders=readRows('orderData',['os','vehicleCode','plate','fleet','year','brand','model','type','ownershipCode','ownership','centerCode','center','centerAcronym','manager','regional','statusCode','status','orderType','maintenance','planCode','plan','km','hourMeter','observation','openDate','start','endCalc','closedDate','finishDate','changeDate','openFlag']).map(function(row){row.year=num(row.year);row.km=txt(row.km)?num(row.km):null;row.hourMeter=txt(row.hourMeter)?num(row.hourMeter):null;row.openDate=parseDate(row.openDate);row.start=parseDate(row.start)||row.openDate;row.endCalc=parseDate(row.endCalc)||row.start;row.closedDate=parseDate(row.closedDate)||parseDate(row.finishDate);row.changeDate=parseDate(row.changeDate);row.openFlag=num(row.openFlag);row.ageBand=ageBand(row.year);row.items=0;row.productCount=0;row.serviceCount=0;row.productCost=0;row.serviceCost=0;row.cost=0;return row}).filter(function(row){return row.start});
    var items=readRows('itemData',['os','sequence','itemType','code','description','macro','sub','productGroup','nature','location','control','partner','observation','quantity','unitValue','totalValue']).map(function(row){row.sequence=num(row.sequence);row.quantity=num(row.quantity);row.unitValue=num(row.unitValue);row.totalValue=num(row.totalValue);row.category=valueOrInfo(txt(row.sub)&&norm(row.sub)!=='nao informado'?row.sub:txt(row.macro)&&norm(row.macro)!=='nao informado'?row.macro:row.productGroup);return row});
    var fleetByCode=new Map(),orderById=new Map(),itemsByOs=new Map();
    fleet.forEach(function(row){fleetByCode.set(row.vehicleCode,row)});
    items.forEach(function(item){if(!itemsByOs.has(item.os))itemsByOs.set(item.os,[]);itemsByOs.get(item.os).push(item)});
    orders.forEach(function(row){var osItems=itemsByOs.get(row.os)||[];row.items=osItems.length;row.productCount=osItems.filter(function(item){return norm(item.itemType)==='produto'}).length;row.serviceCount=osItems.length-row.productCount;row.productCost=sum(osItems,function(item){return norm(item.itemType)==='produto'?item.totalValue:0});row.serviceCost=sum(osItems,function(item){return norm(item.itemType)==='servico'?item.totalValue:0});row.cost=row.productCost+row.serviceCost;row.itemSearch=norm(osItems.map(function(item){return[item.description,item.macro,item.sub,item.productGroup].join(' ')}).join(' '));orderById.set(row.os,row)});
    var maintenanceFleet=fleet.filter(function(row){return row.maintenanceCode==='S'}),activeFleet=(maintenanceFleet.length?maintenanceFleet:fleet).filter(function(row){return row.activeCode==='S'});var eligibleFleet=activeFleet.length?activeFleet:(maintenanceFleet.length?maintenanceFleet:fleet);

    var filterDefs={
        regional:{label:'Regional',values:unique(fleet.map(function(r){return valueOrInfo(r.regional)}).concat(orders.map(function(r){return valueOrInfo(r.regional)})))},
        manager:{label:'Gestor',values:unique(fleet.map(function(r){return valueOrInfo(r.manager)}).concat(orders.map(function(r){return valueOrInfo(r.manager)})))},
        center:{label:'CR',values:unique(fleet.map(centerName).concat(orders.map(centerName)))},
        type:{label:'Tipo',values:unique(fleet.map(function(r){return valueOrInfo(r.type)}).concat(orders.map(function(r){return valueOrInfo(r.type)})))},
        model:{label:'Modelo',values:unique(fleet.map(function(r){return valueOrInfo(r.model)}).concat(orders.map(function(r){return valueOrInfo(r.model)})))},
        maintenance:{label:'Manutenção',values:unique(orders.map(function(r){return valueOrInfo(r.maintenance)}))},
        status:{label:'Status',values:unique(orders.map(function(r){return valueOrInfo(r.status)}))},
        ownership:{label:'Propriedade',values:unique(fleet.map(function(r){return valueOrInfo(r.ownership)}).concat(orders.map(function(r){return valueOrInfo(r.ownership)})))},
        ageBand:{label:'Idade',values:['0-1 ano','2-3 anos','4-5 anos','6-10 anos','11+ anos','Não informado']}
    };
    Object.keys(filterDefs).forEach(function(key){filterDefs[key].selected=new Set()});
    function allowed(key,value){var def=filterDefs[key],selected=def.selected;return selected.size===0||selected.size===def.values.length||selected.has(valueOrInfo(value))}
    function closeMenus(except){Array.prototype.forEach.call(document.querySelectorAll('.multi'),function(wrapper){if(wrapper===except)return;wrapper.querySelector('.multi-menu').hidden=true})}
    function renderFilter(key){var def=filterDefs[key],wrapper=document.querySelector('[data-filter="'+key+'"]'),menu=wrapper.querySelector('.multi-menu'),caption=wrapper.querySelector('.multi-caption');caption.textContent=def.selected.size===0||def.selected.size===def.values.length?'Todos':def.selected.size===1?Array.from(def.selected)[0]:def.selected.size+' selecionados';menu.innerHTML='<div class="multi-actions"><button class="mini-action" type="button" data-action="all">Selecionar todos</button><button class="mini-action" type="button" data-action="clear">Limpar</button></div><div class="multi-options">'+def.values.map(function(value){return'<button class="multi-option '+(def.selected.has(value)?'selected':'')+'" type="button" data-value="'+esc(value)+'"><span class="check"></span><span class="multi-name" title="'+esc(value)+'">'+esc(value)+'</span><span class="multi-count"></span></button>'}).join('')+'</div>'}
    function initFilters(){Object.keys(filterDefs).forEach(function(key){var wrapper=document.querySelector('[data-filter="'+key+'"]'),button=wrapper.querySelector('.multi-button'),menu=wrapper.querySelector('.multi-menu');renderFilter(key);button.addEventListener('click',function(event){event.stopPropagation();var opening=menu.hidden;closeMenus(wrapper);menu.hidden=!opening});menu.addEventListener('click',function(event){event.stopPropagation();var action=event.target.closest('[data-action]'),option=event.target.closest('[data-value]'),def=filterDefs[key];if(action){def.selected.clear();if(action.dataset.action==='all')def.values.forEach(function(value){def.selected.add(value)})}else if(option){var value=option.dataset.value;if(def.selected.has(value))def.selected.delete(value);else def.selected.add(value)}renderFilter(key);render()})});document.addEventListener('click',function(){closeMenus(null)})}
    function stamp(date){return date.getFullYear()+String(date.getMonth()+1).padStart(2,'0')+String(date.getDate()).padStart(2,'0')}
    function stampToDate(value){var raw=txt(value);return /^\d{8}$/.test(raw)?parseDate(raw.slice(0,4)+'-'+raw.slice(4,6)+'-'+raw.slice(6,8)):null}
    function queryParam(name){var match=new RegExp('[?&]'+name+'=([^&#]*)').exec(window.location.search);return match?decodeURIComponent(match[1]):''}
    var loadWindow=(function(){var raw=readRows('windowData',['start','end'])[0]||{},today=new Date(),start=parseDate(raw.start),end=parseDate(raw.end);if(!start)start=new Date(today.getFullYear(),today.getMonth()-6,today.getDate());if(!end)end=today;return{start:start,end:end}})();
    function targetWindow(p){var end=new Date(p.end.getTime()-DAY),span=Math.max(DAY,p.end-p.start);return{start:new Date(p.start.getTime()-span),end:end}}
    function updateLoadState(p){
        var target=targetWindow(p),analysisEnd=new Date(p.end.getTime()-DAY),
            outside=p.start<loadWindow.start||analysisEnd>loadWindow.end,
            needsMore=target.start<new Date(loadWindow.start.getTime()-DAY)||target.end>new Date(loadWindow.end.getTime()+DAY),
            tooWide=loadWindow.start<new Date(target.start.getTime()-31*DAY)||loadWindow.end>new Date(target.end.getTime()+31*DAY),
            differs=needsMore||tooWide,
            button=id('applyPeriod');
        button.disabled=!differs;
        button.classList.toggle('pending',outside);
        button.title=differs?'Recarrega os dados do banco para '+fmtDate(target.start)+' a '+fmtDate(target.end)+' (inclui o período anterior para as comparações).':'A janela carregada já cobre o período selecionado.';
        setText('loadWarning',outside?'Período fora da janela carregada ('+fmtDate(loadWindow.start)+' a '+fmtDate(loadWindow.end)+'). Clique em Aplicar período.':'');
        id('loadWarning').hidden=!outside;
    }
    function applyLoadPeriod(){
        var p=period();if(!p)return;
        var target=targetWindow(p),analysisEnd=new Date(p.end.getTime()-DAY),
            values={dtIni:stamp(target.start),dtFim:stamp(target.end),aIni:stamp(p.start),aFim:stamp(analysisEnd)};
        id('applyPeriod').disabled=true;setText('loadWarning','Carregando o período selecionado...');id('loadWarning').hidden=false;
        try{
            var url=new URL(window.location.href);
            Object.keys(values).forEach(function(key){url.searchParams.set(key,values[key])});
            window.location.href=url.toString();
        }catch(error){
            window.location.search='?'+Object.keys(values).map(function(key){return key+'='+values[key]}).join('&');
        }
    }
    function restorePeriodFromUrl(){var start=stampToDate(queryParam('aIni')),end=stampToDate(queryParam('aFim'));if(!start||!end||start>end)return false;id('dateStart').value=dateInput(start);id('dateEnd').value=dateInput(end);return true}
    function resetPeriod(){var today=new Date(),start=new Date(today.getFullYear(),today.getMonth(),today.getDate()-89),end=today>loadWindow.end?loadWindow.end:today;if(start<loadWindow.start)start=loadWindow.start;if(start>end)start=loadWindow.start;id('dateStart').value=dateInput(start);id('dateEnd').value=dateInput(end)}
    function period(){var start=parseDate(id('dateStart').value),end=parseDate(id('dateEnd').value);if(!start||!end)return null;end=new Date(end.getFullYear(),end.getMonth(),end.getDate()+1);if(start>=end){start=new Date(end.getTime()-DAY);id('dateStart').value=dateInput(start)}return{start:start,end:end,hours:Math.max(24,(end-start)/HOUR),days:Math.max(1,(end-start)/DAY)}}
    function commonMatch(row){return allowed('regional',row.regional)&&allowed('manager',row.manager)&&allowed('center',centerName(row))&&allowed('type',row.type)&&allowed('model',row.model)&&allowed('ownership',row.ownership)&&allowed('ageBand',row.ageBand)}
    function orderMatch(row,search){if(!commonMatch(row)||!allowed('maintenance',row.maintenance)||!allowed('status',row.status))return false;if(!search)return true;return norm([row.os,row.vehicleCode,row.plate,row.fleet,row.brand,row.model,row.type,row.center,row.centerAcronym,row.manager,row.regional,row.status,row.maintenance,row.plan,row.observation,row.itemSearch].join(' ')).indexOf(search)>=0}
    function overlaps(row,p){return row.start<p.end&&row.endCalc>=p.start}
    function intervalHours(rows,p){var intervals=rows.map(function(row){return{start:new Date(Math.max(row.start.getTime(),p.start.getTime())),end:new Date(Math.min(row.endCalc.getTime(),p.end.getTime()))}}).filter(function(x){return x.end>x.start}).sort(function(a,b){return a.start-b.start});if(!intervals.length)return 0;var total=0,current=intervals[0];for(var i=1;i<intervals.length;i++){var next=intervals[i];if(next.start<=current.end){if(next.end>current.end)current.end=next.end}else{total+=(current.end-current.start)/HOUR;current=next}}return total+(current.end-current.start)/HOUR}
    function recurrence(rows){var sets={d30:new Set(),d60:new Set(),d90:new Set()},byVehicle=new Map(),last=new Map();rows.slice().sort(function(a,b){return a.start-b.start}).forEach(function(row){var cats=unique((itemsByOs.get(row.os)||[]).map(function(item){return item.category})).filter(function(cat){return norm(cat)!=='nao informado'});cats.forEach(function(cat){var key=row.vehicleCode+'|'+norm(cat),prior=last.get(key);if(prior&&prior.os!==row.os){var gap=daysBetween(prior.date,row.start);if(gap<=90){sets.d90.add(row.os);sets.d90.add(prior.os);if(gap<=60){sets.d60.add(row.os);sets.d60.add(prior.os)}if(gap<=30){sets.d30.add(row.os);sets.d30.add(prior.os)}}}last.set(key,{os:row.os,date:row.start})})});sets.d90.forEach(function(os){var row=orderById.get(os);if(row)byVehicle.set(row.vehicleCode,(byVehicle.get(row.vehicleCode)||0)+1)});sets.byVehicle=byVehicle;return sets}
    function countKmIssues(rows){var groups=group(rows.filter(function(r){return r.km!==null&&r.km>0}),function(r){return r.vehicleCode}),issues=0;groups.forEach(function(list){var previous=null;list.slice().sort(function(a,b){return a.start-b.start}).forEach(function(row){if(previous!==null&&row.km<previous)issues++;previous=Math.max(previous||0,row.km)})});return issues}
    function aggregate(rows,keyFn,valueFn){return Array.from(group(rows,keyFn),function(entry){return{label:entry[0],rows:entry[1],value:valueFn?valueFn(entry[1]):entry[1].length}}).sort(function(a,b){return b.value-a.value})}
    function buildAnalysis(){var p=period(),search=norm(id('searchInput').value),matchedOrders=orders.filter(function(row){return orderMatch(row,search)}),searchedVehicles=new Set(matchedOrders.map(function(r){return r.vehicleCode})),selectedFleet=eligibleFleet.filter(function(row){if(!commonMatch(row))return false;if(!search)return true;return norm([row.vehicleCode,row.plate,row.fleet,row.brand,row.model,row.type,row.center,row.manager,row.regional].join(' ')).indexOf(search)>=0||searchedVehicles.has(row.vehicleCode)}),selectedCodes=new Set(selectedFleet.map(function(r){return r.vehicleCode})),scopedOrders=matchedOrders;matchedOrders=matchedOrders.filter(function(row){return selectedCodes.has(row.vehicleCode)||!fleetByCode.has(row.vehicleCode)});var historyOrders=scopedOrders.filter(function(row){return row.start>=p.start&&row.start<p.end}),periodOrders=matchedOrders.filter(function(row){return row.start>=p.start&&row.start<p.end}),overlapOrders=matchedOrders.filter(function(row){return overlaps(row,p)}),previous={start:new Date(p.start.getTime()-(p.end-p.start)),end:new Date(p.start),hours:p.hours,days:p.days},previousOrders=matchedOrders.filter(function(row){return row.start>=previous.start&&row.start<previous.end}),previousOverlap=matchedOrders.filter(function(row){return overlaps(row,previous)}),openOrders=matchedOrders.filter(isOpen),rec=recurrence(matchedOrders),periodIds=new Set(periodOrders.map(function(r){return r.os})),periodItems=items.filter(function(item){return periodIds.has(item.os)}),ordersByVehicle=group(periodOrders,function(r){return r.vehicleCode}),overlapByVehicle=group(overlapOrders,function(r){return r.vehicleCode}),openByVehicle=group(openOrders,function(r){return r.vehicleCode});
        var vehicleRows=selectedFleet.map(function(vehicle){var vo=ordersByVehicle.get(vehicle.vehicleCode)||[],ov=overlapByVehicle.get(vehicle.vehicleCode)||[],opened=openByVehicle.get(vehicle.vehicleCode)||[],downtime=intervalHours(ov,p),corrective=vo.filter(isCorrective),preventive=vo.filter(isPreventive),rescues=vo.filter(isRescue),closedCorrective=corrective.filter(function(r){return !isOpen(r)&&r.closedDate&&r.closedDate>=r.start}),repairHours=closedCorrective.map(function(r){return Math.max(0,(r.closedDate-r.start)/HOUR)}),lastOrder=vo.slice().sort(function(a,b){return b.start-a.start})[0],backlogAge=opened.length?Math.max.apply(null,opened.map(function(r){return Math.floor(daysBetween(r.start,new Date()))})):0;return Object.assign({},vehicle,{orders:vo.length,corrective:corrective.length,preventive:preventive.length,rescues:rescues.length,cost:sum(vo,'cost'),productCost:sum(vo,'productCost'),serviceCost:sum(vo,'serviceCost'),downtime:downtime,availability:p.hours?Math.max(0,100-downtime/p.hours*100):100,open:opened.length,backlogAge:backlogAge,mttr:repairHours.length?sum(repairHours,function(x){return x})/repairHours.length:0,lastOrder:lastOrder?lastOrder.start:null,recurrent90:rec.byVehicle.get(vehicle.vehicleCode)||0})});
        var costMedian=median(periodOrders.map(function(r){return r.cost})),openCounts=new Map();openOrders.forEach(function(r){openCounts.set(r.vehicleCode,(openCounts.get(r.vehicleCode)||0)+1)});openOrders.forEach(function(row){row.age=Math.floor(daysBetween(row.start,new Date()));row.stale=Math.floor(daysBetween(row.changeDate||row.start,new Date()));var score=row.age>30?5:row.age>15?4:row.age>7?3:row.age>3?2:row.age>=1?1:0;if(isRescue(row))score+=3;if(isReopened(row))score+=2;if(costMedian>0&&row.cost>=2*costMedian)score+=2;if(rec.d30.has(row.os))score+=2;if((openCounts.get(row.vehicleCode)||0)>1)score+=2;if(!txt(row.observation))score+=1;if(row.stale>=7)score+=1;row.priority=score;row.priorityLabel=score>=8?'Crítica':score>=5?'Alta':score>=3?'Média':'Monitorar'});vehicleRows.forEach(function(row){var signals=0,medianVehicleCost=median(vehicleRows.map(function(x){return x.cost}));if(row.cost>medianVehicleCost&&row.cost>0)signals++;if(row.availability<85)signals++;if(row.recurrent90>1)signals++;if(row.backlogAge>7)signals++;row.attention=signals>=2?'Vermelho':signals===1?'Amarelo':'Verde'});
        var downtime=sum(vehicleRows,'downtime'),availability=selectedFleet.length*p.hours?Math.max(0,100-downtime/(selectedFleet.length*p.hours)*100):100,previousDowntime=sum(selectedFleet,function(v){return intervalHours(previousOverlap.filter(function(r){return r.vehicleCode===v.vehicleCode}),previous)}),previousAvailability=selectedFleet.length*previous.hours?Math.max(0,100-previousDowntime/(selectedFleet.length*previous.hours)*100):100;
        return{period:p,previous:previous,orders:periodOrders,history:historyOrders,overlap:overlapOrders,allMatched:matchedOrders,previousOrders:previousOrders,open:openOrders.sort(function(a,b){return b.priority-a.priority||b.age-a.age}),fleet:selectedFleet,vehicles:vehicleRows,items:periodItems,recurrence:rec,cost:sum(periodOrders,'cost'),productCost:sum(periodOrders,'productCost'),serviceCost:sum(periodOrders,'serviceCost'),costMedian:costMedian,downtime:downtime,availability:availability,previousAvailability:previousAvailability,quality:{noCost:periodOrders.filter(function(r){return r.cost<=0}).length,noObservation:periodOrders.filter(function(r){return !txt(r.observation)}).length,noKm:periodOrders.filter(function(r){return r.km===null}).length,noEnd:periodOrders.filter(isOpen).length,noCenter:selectedFleet.filter(function(r){return norm(r.center)==='nao informado'}).length,noModel:selectedFleet.filter(function(r){return norm(r.model)==='nao informado'}).length,noCategory:periodItems.filter(function(i){return norm(i.category)==='nao informado'}).length,noPartner:periodItems.filter(function(i){return norm(i.partner)==='nao informado'}).length,preventiveNoPlan:periodOrders.filter(function(r){return isPreventive(r)&&!txt(r.planCode)}).length,kmIssues:countKmIssues(matchedOrders)}}
    }

    var state={analysis:null,backlogSort:{key:'priority',dir:'desc'},historySort:{key:'openDate',dir:'desc'},historyRows:[],historySorted:[],historyLimit:300,returnFocus:null,modalRecord:null};
    function setText(elementId,value){id(elementId).textContent=value}
    function delta(current,previous,positiveGood){if(!previous&&previous!==0)return'Sem base anterior';var diff=current-previous,pct=previous?Math.abs(diff/previous*100):0,direction=diff>0?'Alta':diff<0?'Queda':'Estável',good=positiveGood?diff>=0:diff<=0;return'<span class="delta '+(good?'good':'bad')+'">'+direction+' de '+fmtNumber(pct,1)+'% vs. período anterior</span>'}
    function setKpi(valueId,noteId,value,noteHtml){setText(valueId,value);id(noteId).innerHTML=noteHtml}
    function renderRank(containerId,rows,labelFn,valueFn,formatFn,limit){var container=id(containerId),max=rows.length?Math.max.apply(null,rows.map(valueFn)):0;container.innerHTML=rows.slice(0,limit||8).map(function(row,index){var value=valueFn(row),width=max?Math.max(2,value/max*100):0;return'<div class="rank"><span class="rank-no">'+(index+1)+'</span><div><div class="rank-label"><span title="'+esc(labelFn(row))+'">'+esc(labelFn(row))+'</span></div><div class="bar"><i style="width:'+width.toFixed(1)+'%"></i></div></div><strong class="rank-value">'+esc(formatFn(value,row))+'</strong></div>'}).join('')||'<div class="empty">Sem dados no filtro.</div>'}
    function renderKpiCards(containerId,cards){id(containerId).innerHTML=cards.map(function(card){return'<article class="kpi" style="--accent:'+(card.color||'#29b6f6')+';--tint:'+(card.tint||'#e3f4fb')+'"><div class="kpi-head"><span class="kpi-label">'+esc(card.label)+'</span><i class="kpi-dot"></i></div><strong>'+esc(card.value)+'</strong><small>'+esc(card.note||'')+'</small></article>'}).join('')}
    function renderTrend(a){var months=new Map();a.orders.forEach(function(row){var key=row.start.getFullYear()+'-'+String(row.start.getMonth()+1).padStart(2,'0');if(!months.has(key))months.set(key,{key:key,label:row.start.toLocaleDateString('pt-BR',{month:'short',year:'2-digit'}),cost:0,orders:0,corrective:0,preventive:0});var m=months.get(key);m.cost+=row.cost;m.orders++;if(isCorrective(row))m.corrective++;if(isPreventive(row))m.preventive++});var list=Array.from(months.values()).sort(function(x,y){return x.key.localeCompare(y.key)}),maxCost=Math.max.apply(null,list.map(function(x){return x.cost}).concat([1])),maxOrders=Math.max.apply(null,list.map(function(x){return x.orders}).concat([1]));id('monthlyTrend').innerHTML=list.map(function(m){return'<div class="month" title="'+esc(fmtCurrency(m.cost)+' - '+m.orders+' O.S. - '+m.corrective+' corretivas - '+m.preventive+' preventivas')+'"><div class="month-bars"><i class="month-bar" style="height:'+Math.max(1,m.cost/maxCost*100)+'%"></i><i class="month-bar orders" style="height:'+Math.max(1,m.orders/maxOrders*100)+'%"></i></div><span class="month-label">'+esc(m.label.replace('.',''))+'</span><span class="month-value">'+fmtCurrency(m.cost,true)+'</span></div>'}).join('')||'<div class="empty">Sem meses no período.</div>'}
    function renderQuadrant(a){var rows=a.vehicles.filter(function(v){return v.orders>0||v.downtime>0}),costMid=median(rows.map(function(v){return v.cost})),downMid=median(rows.map(function(v){return v.downtime})),groups=[[],[],[],[]];rows.forEach(function(v){var highCost=v.cost>costMid,highDown=v.downtime>downMid,index=highCost&&highDown?1:!highCost&&highDown?0:!highCost&&!highDown?2:3;groups[index].push(v)});var titles=['Baixo custo - Alta parada','Alto custo - Alta parada','Baixo custo - Baixa parada','Alto custo - Baixa parada'];id('quadrant').innerHTML=groups.map(function(list,index){return'<div class="quad"><span class="quad-title">'+titles[index]+'</span><div class="chips">'+list.sort(function(x,y){return y.cost+y.downtime-(x.cost+x.downtime)}).slice(0,10).map(function(v){return'<button class="chip" type="button" data-open-vehicle="'+esc(v.vehicleCode)+'" title="'+esc(fmtCurrency(v.cost)+' - '+fmtHours(v.downtime))+'">'+esc(vehicleName(v))+'</button>'}).join('')+'</div></div>'}).join('')}
    function renderExecutive(a){var corrective=a.orders.filter(isCorrective),preventive=a.orders.filter(isPreventive),openVehicles=new Set(a.open.map(function(r){return r.vehicleCode})),critical=a.open.filter(function(r){return r.age>7}),previousCost=sum(a.previousOrders,'cost'),previousCorrective=a.previousOrders.filter(isCorrective).length;
        setKpi('kpiAvailability','kpiAvailabilityNote',fmtPercent(a.availability),delta(a.availability,a.previousAvailability,true));setKpi('kpiFleet','kpiFleetNote',fmtNumber(a.fleet.length),fmtNumber(a.vehicles.filter(function(v){return v.orders>0}).length)+' com O.S. no período');setKpi('kpiOpenVehicles','kpiOpenVehiclesNote',fmtNumber(openVehicles.size),fmtNumber(a.open.length)+' O.S. abertas');setKpi('kpiCorrective','kpiCorrectiveNote',fmtNumber(corrective.length),delta(corrective.length,previousCorrective,false));setKpi('kpiPreventive','kpiPreventiveNote',fmtPercent(a.orders.length?preventive.length/a.orders.length*100:0),fmtNumber(preventive.length)+' O.S. preventivas');setKpi('kpiCost','kpiCostNote',fmtCurrency(a.cost,true),delta(a.cost,previousCost,false));setKpi('kpiCriticalBacklog','kpiCriticalBacklogNote',fmtNumber(critical.length),fmtNumber(a.open.filter(function(r){return r.age>30}).length)+' acima de 30 dias');renderTrend(a);renderQuadrant(a);
        var topCost=a.vehicles.slice().sort(function(x,y){return y.cost-x.cost}),top10=sum(topCost.slice(0,10),'cost'),share=a.cost?top10/a.cost*100:0,correctivePct=a.orders.length?corrective.length/a.orders.length*100:0,longOpen=a.open.filter(function(r){return r.age>15}).length,regional=aggregate(a.orders,function(r){return r.regional},function(rows){return sum(rows,'cost')})[0];id('executiveSummary').innerHTML=['Os 10 veículos de maior custo concentram '+fmtPercent(share)+' do gasto filtrado.','Corretivas representam '+fmtPercent(correctivePct)+' das O.S. iniciadas no período.',fmtNumber(longOpen)+' O.S. estão abertas há mais de 15 dias.',regional?'A Regional '+regional.label+' concentra o maior custo: '+fmtCurrency(regional.value,true)+'.':'Não há Regional com custo no filtro.'].map(function(text){return'<div class="insight">'+esc(text)+'</div>'}).join('');
        var maxCost=Math.max.apply(null,a.vehicles.map(function(v){return v.cost}).concat([1])),maxDown=Math.max.apply(null,a.vehicles.map(function(v){return v.downtime}).concat([1])),problems=a.vehicles.map(function(v){return{row:v,score:v.cost/maxCost*45+v.downtime/maxDown*35+Math.min(20,v.recurrent90*4)}}).sort(function(x,y){return y.score-x.score});renderRank('topVehicles',problems,function(x){return vehicleName(x.row)},function(x){return x.score},function(value,x){return fmtCurrency(x.row.cost,true)+' - '+fmtHours(x.row.downtime)},10);
        var categories=aggregate(a.items,function(i){return i.category},function(rows){return sum(rows,'totalValue')}),centers=aggregate(a.orders,centerName,function(rows){return sum(rows,'cost')});renderRank('topCategories',categories,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);renderRank('topCenters',centers,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10)
    }
    function priorityClass(label){return label==='Crítica'?'red':label==='Alta'?'orange':label==='Média'?'violet':'blue'}
    var backlogColumns=[['priority','Prioridade'],['os','O.S.'],['vehicle','Veículo'],['plate','Placa'],['type','Tipo'],['center','CR'],['regional','Regional'],['manager','Gestor'],['status','Status'],['maintenance','Manutenção'],['openDate','Abertura'],['age','Dias aberta'],['change','Última alteração'],['stale','Dias sem alteração'],['cost','Custo'],['items','Itens'],['observation','Observação'],['km','KM'],['plan','Plano']],visibleColumns=new Set(backlogColumns.map(function(c){return c[0]}));
    function applyColumns(){backlogColumns.forEach(function(c){var visible=visibleColumns.has(c[0]);Array.prototype.forEach.call(id('backlogTable').querySelectorAll('[data-col="'+c[0]+'"]'),function(cell){cell.style.display=visible?'':'none'})});try{localStorage.setItem('analise_pcm.backlog.columns.v1',JSON.stringify(Array.from(visibleColumns)))}catch(ignore){}}
    function initColumns(){try{var saved=JSON.parse(localStorage.getItem('analise_pcm.backlog.columns.v1'));if(Array.isArray(saved)&&saved.length)visibleColumns=new Set(saved)}catch(ignore){}id('columnMenu').innerHTML=backlogColumns.map(function(c){return'<label class="column-option"><input type="checkbox" data-column="'+c[0]+'" '+(visibleColumns.has(c[0])?'checked':'')+'> '+esc(c[1])+'</label>'}).join('');id('columnButton').addEventListener('click',function(event){event.stopPropagation();id('columnMenu').hidden=!id('columnMenu').hidden});id('columnMenu').addEventListener('click',function(event){event.stopPropagation();var input=event.target.closest('[data-column]');if(!input)return;if(input.checked)visibleColumns.add(input.dataset.column);else if(visibleColumns.size>1)visibleColumns.delete(input.dataset.column);else input.checked=true;applyColumns()});document.addEventListener('click',function(){id('columnMenu').hidden=true})}
    function sortBacklog(rows){var sort=state.backlogSort;return rows.slice().sort(function(a,b){var av=a[sort.key],bv=b[sort.key];if(av instanceof Date)av=av.getTime();if(bv instanceof Date)bv=bv.getTime();var result=typeof av==='string'||typeof bv==='string'?txt(av).localeCompare(txt(bv),'pt-BR',{numeric:true}):num(av)-num(bv);return result*(sort.dir==='asc'?1:-1)})}
    function renderPCM(a){var cards=[['Backlog total',a.open.length,''],['1-3 dias',a.open.filter(function(r){return r.age>=1&&r.age<=3}).length,''],['4-7 dias',a.open.filter(function(r){return r.age>=4&&r.age<=7}).length,''],['8-15 dias',a.open.filter(function(r){return r.age>=8&&r.age<=15}).length,'alert'],['16-30 dias',a.open.filter(function(r){return r.age>=16&&r.age<=30}).length,'alert'],['30+ dias',a.open.filter(function(r){return r.age>30}).length,'critical'],['Reabertas',a.open.filter(isReopened).length,''],['Sem custo',a.open.filter(function(r){return r.cost<=0}).length,'']];id('agingCards').innerHTML=cards.map(function(c){return'<article class="aging-card '+c[2]+'"><span>'+c[0]+'</span><strong>'+fmtNumber(c[1])+'</strong></article>'}).join('');var rows=sortBacklog(a.open);setText('backlogCount',fmtNumber(rows.length)+' O.S.');id('backlogEmpty').hidden=rows.length>0;id('backlogBody').innerHTML=rows.slice(0,250).map(function(r){return'<tr><td data-col="priority"><span class="badge '+priorityClass(r.priorityLabel)+'" title="Score '+r.priority+'">'+esc(r.priorityLabel)+' - '+r.priority+'</span></td><td data-col="os"><button class="link" type="button" data-open-os="'+esc(r.os)+'">O.S. '+esc(r.os)+'</button></td><td data-col="vehicle"><button class="link" type="button" data-open-vehicle="'+esc(r.vehicleCode)+'">'+esc(txt(r.fleet)||r.vehicleCode)+'</button></td><td data-col="plate">'+esc(valueOrInfo(r.plate))+'</td><td data-col="type">'+esc(valueOrInfo(r.type))+'</td><td data-col="center" title="'+esc(centerName(r))+'">'+esc(txt(r.centerAcronym)||r.center)+'</td><td data-col="regional">'+esc(valueOrInfo(r.regional))+'</td><td data-col="manager">'+esc(valueOrInfo(r.manager))+'</td><td data-col="status"><span class="badge '+(isReopened(r)?'violet':'orange')+'">'+esc(r.status)+'</span></td><td data-col="maintenance">'+esc(r.maintenance)+'</td><td data-col="openDate">'+fmtDateTime(r.openDate||r.start)+'</td><td class="num" data-col="age">'+fmtNumber(r.age)+'</td><td data-col="change">'+fmtDateTime(r.changeDate)+'</td><td class="num" data-col="stale">'+fmtNumber(r.stale)+'</td><td class="num" data-col="cost">'+fmtCurrency(r.cost)+'</td><td class="num" data-col="items">'+fmtNumber(r.items)+'</td><td data-col="observation" title="'+esc(r.observation)+'">'+(txt(r.observation)?'Informada':'Não informada')+'</td><td class="num" data-col="km">'+(r.km===null?'--':fmtNumber(r.km))+'</td><td data-col="plan">'+esc(valueOrInfo(r.plan))+'</td></tr>'}).join('');applyColumns()}
    function renderReliability(a){var corrective=a.orders.filter(isCorrective),closed=corrective.filter(function(r){return !isOpen(r)&&r.closedDate&&r.closedDate>=r.start}),durations=closed.map(function(r){return(r.closedDate-r.start)/HOUR}),gaps=[];group(corrective,function(r){return r.vehicleCode}).forEach(function(rows){var sorted=rows.slice().sort(function(x,y){return x.start-y.start});for(var gi=1;gi<sorted.length;gi++)gaps.push(daysBetween(sorted[gi-1].start,sorted[gi].start))});var cards=[{label:'MTTR estimado',value:fmtHours(durations.length?sum(durations,function(x){return x})/durations.length:0),note:'Corretivas finalizadas'},{label:'Reparo mediano',value:fmtHours(median(durations)),note:'Mediana das corretivas'},{label:'Intervalo entre corretivas',value:gaps.length?fmtNumber(sum(gaps,function(x){return x})/gaps.length,1)+' d':'--',note:'Média estimada por veículo'},{label:'Corretivas / veículo',value:fmtNumber(a.fleet.length?corrective.length/a.fleet.length:0,2),note:fmtNumber(corrective.length)+' O.S.'},{label:'Socorros',value:fmtNumber(a.orders.filter(isRescue).length),note:'No período'},{label:'Reaberturas',value:fmtNumber(a.orders.filter(isReopened).length),note:'Status reaberto'},{label:'Retornos',value:fmtNumber(a.orders.filter(isReturn).length),note:'Rótulo de manutenção/tipo'},{label:'Reincidentes 30d',value:fmtNumber(a.recurrence.d30.size),note:'O.S. envolvidas'},{label:'Reincidentes 90d',value:fmtNumber(a.recurrence.d90.size),note:'O.S. envolvidas'}];renderKpiCards('reliabilityKpis',cards);var correctiveByVehicle=aggregate(corrective,function(r){return vehicleName(r)}),models=aggregate(a.vehicles,function(v){return v.model},function(rows){return sum(rows,'recurrent90')}),types=aggregate(corrective,function(r){return r.type}),categoryOs=new Map();a.items.forEach(function(item){var key=item.category;if(!categoryOs.has(key))categoryOs.set(key,new Set());categoryOs.get(key).add(item.os)});var cats=Array.from(categoryOs,function(entry){return{label:entry[0],value:entry[1].size}}).sort(function(x,y){return y.value-x.value});renderRank('correctiveVehicles',correctiveByVehicle,function(x){return x.label},function(x){return x.value},function(v){return fmtNumber(v)+' O.S.'},10);renderRank('recurrentModels',models,function(x){return x.label},function(x){return x.value},function(v){return fmtNumber(v)+' ocorr.'},10);renderRank('failureCategories',cats,function(x){return x.label},function(x){return x.value},function(v){return fmtNumber(v)+' O.S.'},10);renderRank('reliabilityTypes',types,function(x){return x.label},function(x){return x.value},function(v){return fmtNumber(v)+' corretivas'},10);var rows=a.vehicles.filter(function(v){return v.orders>0}).sort(function(x,y){return y.corrective-x.corrective||y.recurrent90-x.recurrent90});setText('reliabilityCount',fmtNumber(rows.length)+' veículos');id('reliabilityBody').innerHTML=rows.slice(0,250).map(function(v){return'<tr><td><button class="link" type="button" data-open-vehicle="'+esc(v.vehicleCode)+'">'+esc(vehicleName(v))+'</button></td><td class="num">'+fmtNumber(v.corrective)+'</td><td class="num">'+fmtNumber(v.preventive)+'</td><td class="num">'+fmtNumber(v.rescues)+'</td><td class="num">'+(v.lastOrder?fmtNumber(Math.floor(daysBetween(v.lastOrder,new Date()))):'--')+'</td><td class="num">'+fmtCurrency(v.cost)+'</td><td class="num">'+fmtHours(v.downtime)+'</td><td class="num">'+fmtHours(v.mttr)+'</td><td class="num">'+fmtNumber(v.recurrent90)+'</td></tr>'}).join('')}
    function paretoRows(rows,labelFn,valueFn){var sorted=rows.slice().sort(function(a,b){return valueFn(b)-valueFn(a)}),total=sum(sorted,valueFn),running=0,result=[];for(var i=0;i<sorted.length;i++){var value=valueFn(sorted[i]);running+=value;result.push({label:labelFn(sorted[i]),value:value,pct:total?running/total*100:0});if(total&&running/total>=.8)break}return result}
    function renderPareto(containerId,rows){id(containerId).innerHTML=rows.map(function(r){return'<div class="pareto-row"><span class="pareto-name" title="'+esc(r.label)+'">'+esc(r.label)+'</span><span class="pareto-value">'+fmtCurrency(r.value,true)+'</span><span class="pareto-pct">'+fmtPercent(r.pct)+'</span></div>'}).join('')||'<div class="empty">Sem custos.</div>'}
    function renderCosts(a){var costs=a.orders.map(function(r){return r.cost}),med=median(costs),above2=a.orders.filter(function(r){return med>0&&r.cost>=2*med}).length,above3=a.orders.filter(function(r){return med>0&&r.cost>=3*med}).length,cards=[{label:'Custo total',value:fmtCurrency(a.cost,true),note:fmtNumber(a.orders.length)+' O.S.'},{label:'Produtos',value:fmtCurrency(a.productCost,true),note:fmtPercent(a.cost?a.productCost/a.cost*100:0)},{label:'Serviços',value:fmtCurrency(a.serviceCost,true),note:fmtPercent(a.cost?a.serviceCost/a.cost*100:0)},{label:'Custo médio',value:fmtCurrency(a.orders.length?a.cost/a.orders.length:0,true),note:'Por O.S.'},{label:'Mediana',value:fmtCurrency(med,true),note:above2+' acima de 2x - '+above3+' acima de 3x'},{label:'O.S. sem custo',value:fmtNumber(a.orders.filter(function(r){return r.cost<=0}).length),note:'Revisar lançamentos'},{label:'Itens lançados',value:fmtNumber(a.items.length),note:'Produtos + serviços'}];renderKpiCards('costKpis',cards);var regional=aggregate(a.orders,function(r){return r.regional},function(rows){return sum(rows,'cost')}),manager=aggregate(a.orders,function(r){return r.manager},function(rows){return sum(rows,'cost')}),maintenance=aggregate(a.orders,function(r){return r.maintenance},function(rows){return sum(rows,'cost')}),centers=aggregate(a.orders,centerName,function(rows){return sum(rows,'cost')}),types=aggregate(a.orders,function(r){return r.type},function(rows){return sum(rows,'cost')}),ages=aggregate(a.orders,function(r){return r.ageBand},function(rows){return sum(rows,'cost')});renderRank('costRegional',regional,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);renderRank('costManager',manager,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);renderRank('costMaintenance',maintenance,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);renderRank('costCenters',centers,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);renderRank('costTypes',types,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);renderRank('costAges',ages,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);var macro=aggregate(a.items,function(i){return i.macro},function(rows){return sum(rows,'totalValue')}),sub=aggregate(a.items,function(i){return i.sub},function(rows){return sum(rows,'totalValue')}),groups=aggregate(a.items,function(i){return i.productGroup},function(rows){return sum(rows,'totalValue')});renderRank('costMacro',macro,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);renderRank('costSub',sub,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);renderRank('costGroup',groups,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);renderPareto('paretoVehicles',paretoRows(a.vehicles.filter(function(v){return v.cost>0}),vehicleName,function(v){return v.cost}));var categories=aggregate(a.items,function(i){return i.category},function(rows){return sum(rows,'totalValue')});renderPareto('paretoCategories',paretoRows(categories,function(x){return x.label},function(x){return x.value}));var itemCost=aggregate(a.items,function(i){return i.description},function(rows){return sum(rows,'totalValue')}),itemQty=aggregate(a.items,function(i){return i.description},function(rows){return sum(rows,'quantity')}),models=aggregate(a.vehicles,function(v){return v.model},function(rows){return sum(rows,'cost')});renderRank('expensiveItems',itemCost,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10);renderRank('consumedItems',itemQty,function(x){return x.label},function(x){return x.value},function(v){return fmtNumber(v,2)},10);renderRank('costModels',models,function(x){return x.label},function(x){return x.value},function(v){return fmtCurrency(v,true)},10)}
    function attentionClass(value){return value==='Vermelho'?'red':value==='Amarelo'?'orange':'green'}
    function renderFleet(a){var rows=a.vehicles.slice().sort(function(x,y){var rank={Vermelho:3,Amarelo:2,Verde:1};return rank[y.attention]-rank[x.attention]||y.cost-x.cost});setText('fleetTableCount',fmtNumber(rows.length)+' veículos');id('fleetEmpty').hidden=rows.length>0;id('fleetBody').innerHTML=rows.slice(0,300).map(function(v){return'<tr><td><button class="link" type="button" data-open-vehicle="'+esc(v.vehicleCode)+'">'+esc(vehicleName(v))+'</button><span class="secondary-text">Cód. '+esc(v.vehicleCode)+'</span></td><td><span class="primary-text">'+esc(v.type)+'</span><span class="secondary-text">'+esc(v.brand+' - '+v.model)+'</span></td><td>'+esc(v.year?fmtNumber(v.year):'--')+' - '+esc(v.age===null?'--':fmtNumber(v.age)+' anos')+'</td><td title="'+esc(centerName(v)+' - '+v.regional+' - '+v.manager)+'">'+esc(txt(v.centerAcronym)||v.center)+' - '+esc(v.regional)+'</td><td>'+esc(v.ownership)+'</td><td class="num">'+fmtNumber(v.kmCurrent)+'</td><td class="num">'+fmtNumber(v.orders)+'</td><td class="num">'+fmtNumber(v.corrective)+'</td><td class="num">'+fmtNumber(v.preventive)+'</td><td class="num">'+fmtNumber(v.rescues)+'</td><td class="num">'+fmtCurrency(v.cost)+'</td><td class="num">'+fmtHours(v.downtime)+'</td><td class="num">'+fmtPercent(v.availability)+'</td><td class="num">'+fmtHours(v.mttr)+'</td><td class="num">'+fmtNumber(v.open)+'</td><td class="num">'+fmtNumber(v.backlogAge)+'</td><td><span class="badge '+attentionClass(v.attention)+'">'+esc(v.attention)+'</span></td></tr>'}).join('')}
    var HISTORY_PAGE=300,HISTORY_STORAGE='analise_pcm.history.columns.v1';
    function historyVehicleLabel(row){return txt(row.fleet)||row.vehicleCode}
    function statusClass(row){return isReopened(row.source)?'violet':row.open?'orange':'green'}
    var historyColumns=[
        {key:'os',label:'O.S.',type:'string',width:12,visible:true,value:function(v){return v.os},html:function(v){return'<button class="link" type="button" data-open-os="'+esc(v.os)+'">O.S. '+esc(v.os)+'</button>'}},
        {key:'openDate',label:'Abertura',type:'date',width:18,visible:true,value:function(v){return v.openDate},html:function(v){return fmtDateTime(v.openDate)}},
        {key:'closeDate',label:'Encerramento',type:'date',width:18,visible:true,value:function(v){return v.closeDate},html:function(v){return v.closeDate?fmtDateTime(v.closeDate):'--'}},
        {key:'start',label:'Início',type:'date',width:18,visible:false,value:function(v){return v.start},html:function(v){return fmtDateTime(v.start)}},
        {key:'duration',label:'Duração',exportLabel:'Duração (h)',type:'decimal',align:'num',width:13,visible:true,value:function(v){return Math.round(v.duration*10)/10},html:function(v){return fmtHours(v.duration)}},
        {key:'days',label:'Dias',type:'number',align:'num',width:8,visible:false,value:function(v){return v.days},html:function(v){return fmtNumber(v.days)}},
        {key:'changeDate',label:'Última alteração',type:'date',width:18,visible:false,value:function(v){return v.changeDate},html:function(v){return fmtDateTime(v.changeDate)}},
        {key:'vehicle',label:'Veículo',type:'string',width:16,visible:true,value:function(v){return historyVehicleLabel(v)},html:function(v){return'<button class="link" type="button" data-open-vehicle="'+esc(v.vehicleCode)+'">'+esc(historyVehicleLabel(v))+'</button>'}},
        {key:'plate',label:'Placa',type:'string',width:12,visible:true,value:function(v){return valueOrInfo(v.plate)},html:function(v){return esc(valueOrInfo(v.plate))}},
        {key:'type',label:'Tipo',type:'string',width:16,visible:true,value:function(v){return valueOrInfo(v.type)},html:function(v){return esc(valueOrInfo(v.type))}},
        {key:'model',label:'Modelo',type:'string',width:18,visible:false,value:function(v){return valueOrInfo(v.model)},html:function(v){return esc(valueOrInfo(v.model))}},
        {key:'center',label:'CR',type:'string',width:18,visible:true,value:function(v){return v.center},html:function(v){return'<span title="'+esc(v.center)+'">'+esc(txt(v.centerAcronym)||v.center)+'</span>'}},
        {key:'regional',label:'Regional',type:'string',width:16,visible:true,value:function(v){return valueOrInfo(v.regional)},html:function(v){return esc(valueOrInfo(v.regional))}},
        {key:'manager',label:'Gestor',type:'string',width:16,visible:true,value:function(v){return valueOrInfo(v.manager)},html:function(v){return esc(valueOrInfo(v.manager))}},
        {key:'situation',label:'Situação',type:'string',width:12,visible:true,value:function(v){return v.situation},html:function(v){return'<span class="badge '+(v.open?'orange':'green')+'">'+esc(v.situation)+'</span>'}},
        {key:'status',label:'Status',type:'string',width:14,visible:true,value:function(v){return valueOrInfo(v.status)},html:function(v){return'<span class="badge '+statusClass(v)+'">'+esc(valueOrInfo(v.status))+'</span>'}},
        {key:'maintenance',label:'Manutenção',type:'string',width:14,visible:true,value:function(v){return valueOrInfo(v.maintenance)},html:function(v){return esc(valueOrInfo(v.maintenance))}},
        {key:'orderType',label:'Tipo O.S.',type:'string',width:14,visible:false,value:function(v){return valueOrInfo(v.orderType)},html:function(v){return esc(valueOrInfo(v.orderType))}},
        {key:'plan',label:'Plano',type:'string',width:18,visible:false,value:function(v){return valueOrInfo(v.plan)},html:function(v){return esc(valueOrInfo(v.plan))}},
        {key:'km',label:'KM',type:'number',align:'num',width:12,visible:true,value:function(v){return v.km},html:function(v){return v.km===null?'--':fmtNumber(v.km)}},
        {key:'items',label:'Itens',type:'number',align:'num',width:8,visible:true,value:function(v){return v.items},html:function(v){return fmtNumber(v.items)}},
        {key:'productCost',label:'Custo produtos',type:'currency',align:'num',width:15,visible:false,value:function(v){return v.productCost},html:function(v){return fmtCurrency(v.productCost)}},
        {key:'serviceCost',label:'Custo serviços',type:'currency',align:'num',width:15,visible:false,value:function(v){return v.serviceCost},html:function(v){return fmtCurrency(v.serviceCost)}},
        {key:'cost',label:'Custo total',type:'currency',align:'num',width:15,visible:true,value:function(v){return v.cost},html:function(v){return fmtCurrency(v.cost)}},
        {key:'observation',label:'Observação',type:'string',width:45,visible:true,value:function(v){return v.observation},html:function(v){return'<span title="'+esc(v.observation)+'">'+esc(txt(v.observation)||'Não informada')+'</span>'}}
    ];
    var historyVisible=new Set(historyColumns.filter(function(c){return c.visible}).map(function(c){return c.key}));
    function buildHistoryRows(a){return a.history.map(function(r){var open=isOpen(r),closeDate=open?null:(r.closedDate||r.finishDate||null),reference=open?new Date():(closeDate||r.endCalc),duration=Math.max(0,(reference-r.start)/HOUR);return{source:r,os:r.os,vehicleCode:r.vehicleCode,fleet:r.fleet,plate:r.plate,type:r.type,model:r.model,center:centerName(r),centerAcronym:r.centerAcronym,regional:r.regional,manager:r.manager,open:open,situation:open?'Aberta':'Encerrada',status:r.status,maintenance:r.maintenance,orderType:r.orderType,plan:r.plan,openDate:r.openDate||r.start,start:r.start,closeDate:closeDate,changeDate:r.changeDate,duration:duration,days:Math.floor(duration/24),km:r.km,items:r.items,productCost:r.productCost,serviceCost:r.serviceCost,cost:r.cost,observation:r.observation}})}
    function historyColumn(key){for(var i=0;i<historyColumns.length;i++)if(historyColumns[i].key===key)return historyColumns[i];return null}
    function sortHistory(rows){var sort=state.historySort,column=historyColumn(sort.key);if(!column)return rows.slice();return rows.slice().sort(function(a,b){var av=column.value(a),bv=column.value(b),empty=function(x){return x===null||x===undefined||x===''};if(empty(av)&&empty(bv))return 0;if(empty(av))return 1;if(empty(bv))return-1;if(av instanceof Date)av=av.getTime();if(bv instanceof Date)bv=bv.getTime();var result=column.type==='string'?txt(av).localeCompare(txt(bv),'pt-BR',{numeric:true}):num(av)-num(bv);return result*(sort.dir==='asc'?1:-1)})}
    function applyHistoryColumns(){historyColumns.forEach(function(c){var visible=historyVisible.has(c.key);Array.prototype.forEach.call(id('historyTable').querySelectorAll('[data-col="'+c.key+'"]'),function(cell){cell.style.display=visible?'':'none'})});try{localStorage.setItem(HISTORY_STORAGE,JSON.stringify(Array.from(historyVisible)))}catch(ignore){}}
    function renderHistoryHead(){id('historyHead').innerHTML=historyColumns.map(function(c){var active=state.historySort.key===c.key;return'<th data-col="'+c.key+'" data-sort="'+c.key+'"'+(c.align==='num'?' class="num"':'')+' title="Ordenar por '+esc(c.label)+'">'+esc(c.label)+(active?'<span class="sort-mark">'+(state.historySort.dir==='asc'?'▲':'▼')+'</span>':'')+'</th>'}).join('')}
    function renderHistoryMenu(){id('historyColumnMenu').innerHTML='<div class="multi-actions"><button class="mini-action" type="button" data-history-columns="reset">Restaurar colunas</button></div>'+historyColumns.map(function(c){return'<label class="column-option"><input type="checkbox" data-history-column="'+c.key+'" '+(historyVisible.has(c.key)?'checked':'')+'> '+esc(c.label)+'</label>'}).join('')}
    function initHistoryColumns(){
        try{var saved=JSON.parse(localStorage.getItem(HISTORY_STORAGE));if(Array.isArray(saved)&&saved.length){var valid=saved.filter(function(key){return!!historyColumn(key)});if(valid.length)historyVisible=new Set(valid)}}catch(ignore){}
        renderHistoryMenu();
        id('historyColumnButton').addEventListener('click',function(event){event.stopPropagation();id('historyColumnMenu').hidden=!id('historyColumnMenu').hidden});
        id('historyColumnMenu').addEventListener('click',function(event){event.stopPropagation();var reset=event.target.closest('[data-history-columns]'),input=event.target.closest('[data-history-column]');if(reset){historyVisible=new Set(historyColumns.filter(function(c){return c.visible}).map(function(c){return c.key}));renderHistoryMenu();applyHistoryColumns();return}if(!input)return;if(input.checked)historyVisible.add(input.dataset.historyColumn);else if(historyVisible.size>1)historyVisible.delete(input.dataset.historyColumn);else input.checked=true;applyHistoryColumns()});
        document.addEventListener('click',function(){id('historyColumnMenu').hidden=true});
    }
    function renderHistoryCards(rows){var open=rows.filter(function(v){return v.open}),cards=[['O.S. no período',fmtNumber(rows.length),''],['Encerradas',fmtNumber(rows.length-open.length),''],['Em aberto',fmtNumber(open.length),open.length?'alert':''],['Corretivas',fmtNumber(rows.filter(function(v){return isCorrective(v.source)}).length),''],['Preventivas',fmtNumber(rows.filter(function(v){return isPreventive(v.source)}).length),''],['Socorros',fmtNumber(rows.filter(function(v){return isRescue(v.source)}).length),''],['Reabertas',fmtNumber(rows.filter(function(v){return isReopened(v.source)}).length),''],['Custo total',fmtCurrency(sum(rows,'cost'),true),'money']];id('historyCards').innerHTML=cards.map(function(c){return'<article class="aging-card '+c[2]+'"><span>'+c[0]+'</span><strong>'+c[1]+'</strong></article>'}).join('')}
    function renderHistory(a,keepLimit){
        if(a){state.historyRows=buildHistoryRows(a);if(!keepLimit)state.historyLimit=HISTORY_PAGE;renderHistoryCards(state.historyRows)}
        var rows=sortHistory(state.historyRows);state.historySorted=rows;
        var limit=Math.min(state.historyLimit,rows.length);
        setText('historyCount',fmtNumber(rows.length)+' O.S.');
        id('historyEmpty').hidden=rows.length>0;
        renderHistoryHead();
        id('historyBody').innerHTML=rows.slice(0,limit).map(function(v){return'<tr>'+historyColumns.map(function(c){return'<td data-col="'+c.key+'"'+(c.align==='num'?' class="num"':'')+'>'+c.html(v)+'</td>'}).join('')+'</tr>'}).join('');
        setText('historyShown',rows.length?'Exibindo '+fmtNumber(limit)+' de '+fmtNumber(rows.length)+' O.S. - a exportação inclui todas as linhas filtradas':'Nenhuma O.S. no período filtrado');
        id('historyMore').hidden=limit>=rows.length;
        setText('historyMore','Carregar mais '+fmtNumber(Math.min(HISTORY_PAGE,rows.length-limit)));
        applyHistoryColumns();
    }
    var CRC_TABLE=(function(){var table=new Int32Array(256),i,k,c;for(i=0;i<256;i++){c=i;for(k=0;k<8;k++)c=c&1?0xEDB88320^(c>>>1):c>>>1;table[i]=c}return table})();
    function crc32(bytes){var crc=-1,i;for(i=0;i<bytes.length;i++)crc=(crc>>>8)^CRC_TABLE[(crc^bytes[i])&0xFF];return(crc^-1)>>>0}
    function utf8Bytes(text){if(typeof TextEncoder==='function')return new TextEncoder().encode(text);var out=[],i,c;for(i=0;i<text.length;i++){c=text.charCodeAt(i);if(c<128)out.push(c);else if(c<2048)out.push(192|(c>>6),128|(c&63));else if(c<55296||c>57343)out.push(224|(c>>12),128|((c>>6)&63),128|(c&63));else{c=65536+(((c&1023)<<10)|(text.charCodeAt(++i)&1023));out.push(240|(c>>18),128|((c>>12)&63),128|((c>>6)&63),128|(c&63))}}return new Uint8Array(out)}
    function zipArchive(entries){
        var parts=[],central=[],offset=0,centralSize=0,i,total=0,result,cursor=0;
        entries.forEach(function(entry){
            var name=utf8Bytes(entry.name),data=entry.data,crc=crc32(data),local=new Uint8Array(30+name.length),view=new DataView(local.buffer),dir=new Uint8Array(46+name.length),dirView=new DataView(dir.buffer);
            view.setUint32(0,0x04034b50,true);view.setUint16(4,20,true);view.setUint16(6,0x0800,true);view.setUint16(8,0,true);view.setUint16(10,0,true);view.setUint16(12,0x21,true);
            view.setUint32(14,crc,true);view.setUint32(18,data.length,true);view.setUint32(22,data.length,true);view.setUint16(26,name.length,true);view.setUint16(28,0,true);local.set(name,30);
            dirView.setUint32(0,0x02014b50,true);dirView.setUint16(4,20,true);dirView.setUint16(6,20,true);dirView.setUint16(8,0x0800,true);dirView.setUint16(10,0,true);dirView.setUint16(12,0,true);dirView.setUint16(14,0x21,true);
            dirView.setUint32(16,crc,true);dirView.setUint32(20,data.length,true);dirView.setUint32(24,data.length,true);dirView.setUint16(28,name.length,true);dirView.setUint16(30,0,true);dirView.setUint16(32,0,true);
            dirView.setUint16(34,0,true);dirView.setUint16(36,0,true);dirView.setUint32(38,0,true);dirView.setUint32(42,offset,true);dir.set(name,46);
            parts.push(local,data);central.push(dir);offset+=local.length+data.length;centralSize+=dir.length;
        });
        var end=new Uint8Array(22),endView=new DataView(end.buffer);
        endView.setUint32(0,0x06054b50,true);endView.setUint16(4,0,true);endView.setUint16(6,0,true);endView.setUint16(8,entries.length,true);endView.setUint16(10,entries.length,true);
        endView.setUint32(12,centralSize,true);endView.setUint32(16,offset,true);endView.setUint16(20,0,true);
        parts=parts.concat(central);parts.push(end);
        for(i=0;i<parts.length;i++)total+=parts[i].length;
        result=new Uint8Array(total);
        for(i=0;i<parts.length;i++){result.set(parts[i],cursor);cursor+=parts[i].length}
        return result;
    }
    function xmlEsc(value){return txt(value).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;')}
    function colRef(index){var name='',position=index+1,rest;while(position>0){rest=(position-1)%26;name=String.fromCharCode(65+rest)+name;position=Math.floor((position-1)/26)}return name}
    function excelSerial(date){return(Date.UTC(date.getFullYear(),date.getMonth(),date.getDate(),date.getHours(),date.getMinutes(),date.getSeconds())-Date.UTC(1899,11,30))/86400000}
    function xlsxCell(ref,value,type){
        if(value===null||value===undefined||value==='')return'<c r="'+ref+'"/>';
        if(type==='date')return value instanceof Date?'<c r="'+ref+'" s="2"><v>'+excelSerial(value)+'</v></c>':'<c r="'+ref+'"/>';
        if(type==='currency')return'<c r="'+ref+'" s="3"><v>'+num(value)+'</v></c>';
        if(type==='number')return'<c r="'+ref+'" s="4"><v>'+num(value)+'</v></c>';
        if(type==='decimal')return'<c r="'+ref+'" s="5"><v>'+num(value)+'</v></c>';
        return'<c r="'+ref+'" t="inlineStr"><is><t xml:space="preserve">'+xmlEsc(value)+'</t></is></c>';
    }
    function buildXlsx(sheetName,columns,rows){
        var head='<row r="1">'+columns.map(function(column,index){return'<c r="'+colRef(index)+'1" t="inlineStr" s="1"><is><t>'+xmlEsc(column.label)+'</t></is></c>'}).join('')+'</row>',
            body=rows.map(function(row,rowIndex){return'<row r="'+(rowIndex+2)+'">'+columns.map(function(column,index){return xlsxCell(colRef(index)+(rowIndex+2),row[index],column.type)}).join('')+'</row>'}).join(''),
            cols='<cols>'+columns.map(function(column,index){return'<col min="'+(index+1)+'" max="'+(index+1)+'" width="'+(column.width||16)+'" customWidth="1"/>'}).join('')+'</cols>',
            reference='A1:'+colRef(Math.max(0,columns.length-1))+(rows.length+1),
            sheet='<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><dimension ref="'+reference+'"/><sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews><sheetFormatPr defaultRowHeight="14"/>'+cols+'<sheetData>'+head+body+'</sheetData><autoFilter ref="'+reference+'"/></worksheet>',
            styles='<?xml version="1.0" encoding="UTF-8" standalone="yes"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><numFmts count="3"><numFmt numFmtId="164" formatCode="dd/mm/yyyy\\ hh:mm"/><numFmt numFmtId="165" formatCode="&quot;R$&quot;\\ #,##0.00"/><numFmt numFmtId="166" formatCode="#,##0.0"/></numFmts><fonts count="2"><font><sz val="10"/><name val="Calibri"/></font><font><b/><sz val="10"/><color rgb="FFFFFFFF"/><name val="Calibri"/></font></fonts><fills count="3"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill><fill><patternFill patternType="solid"><fgColor rgb="FF123A5D"/><bgColor indexed="64"/></patternFill></fill></fills><borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders><cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs><cellXfs count="6"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1"/><xf numFmtId="164" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/><xf numFmtId="165" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/><xf numFmtId="3" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/><xf numFmtId="166" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/></cellXfs><cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles></styleSheet>',
            book='<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="'+xmlEsc(txt(sheetName).replace(/[\\\/\?\*\[\]:]/g,' ').substring(0,31)||'Dados')+'" sheetId="1" r:id="rId1"/></sheets></workbook>',
            types='<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/><Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/></Types>',
            rootRels='<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>',
            bookRels='<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>';
        return zipArchive([{name:'[Content_Types].xml',data:utf8Bytes(types)},{name:'_rels/.rels',data:utf8Bytes(rootRels)},{name:'xl/workbook.xml',data:utf8Bytes(book)},{name:'xl/_rels/workbook.xml.rels',data:utf8Bytes(bookRels)},{name:'xl/styles.xml',data:utf8Bytes(styles)},{name:'xl/worksheets/sheet1.xml',data:utf8Bytes(sheet)}]);
    }
    function downloadBlob(blob,fileName){var link=document.createElement('a');link.href=URL.createObjectURL(blob);link.download=fileName;document.body.appendChild(link);link.click();link.remove();URL.revokeObjectURL(link.href)}
    function historyExportColumns(){return historyColumns.filter(function(c){return historyVisible.has(c.key)})}
    function exportHistoryXlsx(){
        var rows=state.historySorted||[],columns=historyExportColumns();
        if(!rows.length){window.alert('Não há O.S. para exportar com os filtros atuais.');return}
        try{
            var bytes=buildXlsx('Histórico O.S.',columns.map(function(c){return{label:c.exportLabel||c.label,type:c.type,width:c.width||16}}),rows.map(function(v){return columns.map(function(c){return c.value(v)})}));
            downloadBlob(new Blob([bytes],{type:'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'}),'historico_os_'+dateInput(new Date())+'.xlsx');
        }catch(error){window.alert('Não foi possível gerar o XLSX neste navegador. Use a exportação CSV.')}
    }
    function historyCsvValue(column,row){var value=column.value(row);if(value===null||value===undefined)return'';if(value instanceof Date)return fmtDateTime(value);if(column.type==='currency'||column.type==='decimal')return num(value).toFixed(2).replace('.',',');if(column.type==='number')return String(num(value));return txt(value)}
    function exportHistoryCsv(){
        var rows=state.historySorted||[],columns=historyExportColumns();
        if(!rows.length){window.alert('Não há O.S. para exportar com os filtros atuais.');return}
        var lines=[columns.map(function(c){return csvCell(c.exportLabel||c.label)}).join(';')];
        rows.forEach(function(row){lines.push(columns.map(function(c){return csvCell(historyCsvValue(c,row))}).join(';'))});
        downloadBlob(new Blob(['\ufeff'+lines.join('\r\n')],{type:'text/csv;charset=utf-8;'}),'historico_os_'+dateInput(new Date())+'.csv');
    }
    function renderQuality(a){var q=a.quality,rows=[['O.S. sem custo',q.noCost],['O.S. sem observação',q.noObservation],['O.S. sem KM',q.noKm],['O.S. sem encerramento',q.noEnd],['Veículo sem CR',q.noCenter],['Veículo sem modelo',q.noModel],['Itens sem categoria',q.noCategory],['Itens sem parceiro',q.noPartner],['Preventiva sem plano',q.preventiveNoPlan],['KM aparentemente inconsistente',q.kmIssues]];openModal('Qualidade da informação','Pontos cadastrais a revisar no filtro atual','Qualidade e governança','<div class="quality-list">'+rows.map(function(r){return'<div class="quality-item"><span>'+esc(r[0])+'</span><strong>'+fmtNumber(r[1])+'</strong></div>'}).join('')+'</div><p class="method" style="margin-top:12px">KM inconsistente identifica regressão entre O.S. cronologicamente ordenadas do mesmo veículo. É um alerta para revisão, não uma correção automática.</p>',null)}
    function detail(label,value,cls){return'<div class="detail '+(cls||'')+'"><span>'+esc(label)+'</span><strong>'+esc(valueOrInfo(value))+'</strong></div>'}
    function metric(label,value){return'<div class="modal-metric"><span>'+esc(label)+'</span><strong>'+esc(value)+'</strong></div>'}
    function miniTable(headers,rows){return'<div class="table-wrap" style="max-height:300px"><table class="data-table"><thead><tr>'+headers.map(function(h){return'<th>'+esc(h)+'</th>'}).join('')+'</tr></thead><tbody>'+rows.join('')+'</tbody></table></div>'}
    function openOrder(row,trigger){if(!row)return;var osItems=itemsByOs.get(row.os)||[],duration=row.closedDate&&row.closedDate>=row.start?(row.closedDate-row.start)/HOUR:(row.endCalc-row.start)/HOUR,head='<div class="modal-kpis">'+metric('Status',row.status)+metric('Duração',fmtHours(duration))+metric('Custo total',fmtCurrency(row.cost))+metric('Produtos',fmtCurrency(row.productCost))+metric('Serviços',fmtCurrency(row.serviceCost))+metric('Itens',fmtNumber(row.items))+'</div><div class="detail-grid">'+detail('Veículo',vehicleName(row))+detail('Tipo',row.type)+detail('CR / Regional',centerName(row)+' - '+row.regional,'span2')+detail('Gestor',row.manager)+detail('Manutenção',row.maintenance)+detail('Tipo da O.S.',row.orderType)+detail('Plano',[row.planCode,row.plan].filter(Boolean).join(' - '))+detail('Abertura',fmtDateTime(row.openDate))+detail('Início',fmtDateTime(row.start))+detail('Encerramento',isOpen(row)?'--':fmtDateTime(row.closedDate))+detail('Última alteração',fmtDateTime(row.changeDate))+detail('KM',row.km===null?'--':fmtNumber(row.km))+detail('Horímetro',row.hourMeter===null?'--':fmtNumber(row.hourMeter))+detail('Observação',row.observation,'full')+'</div>',itemRows=osItems.map(function(item){return'<tr><td><span class="badge '+(norm(item.itemType)==='servico'?'violet':'blue')+'">'+esc(item.itemType)+'</span></td><td>'+esc(item.code)+'</td><td title="'+esc(item.observation)+'">'+esc(item.description)+'</td><td>'+esc(item.macro)+'</td><td>'+esc(item.sub)+'</td><td>'+esc(item.productGroup)+'</td><td class="num">'+fmtNumber(item.quantity,2)+'</td><td class="num">'+fmtCurrency(item.unitValue)+'</td><td class="num">'+fmtCurrency(item.totalValue)+'</td><td>'+esc(valueOrInfo(item.partner))+'</td></tr>'}),body=head+'<section class="modal-section"><div class="panel-head"><div><h3 class="panel-title">Produtos e serviços</h3><p class="panel-subtitle">Valores e classificações vinculados à O.S.</p></div></div>'+miniTable(['Tipo','Código','Descrição','Categoria','Sub-categoria','Grupo','Qtd.','Valor unit.','Valor total','Parceiro'],itemRows)+'</section>';openModal('O.S. #'+row.os,vehicleName(row)+' - '+centerName(row),'Resumo operacional',body,{type:'os',value:row.os,trigger:trigger})}
    function openVehicle(code,trigger){var a=state.analysis,vehicle=a.vehicles.find(function(v){return v.vehicleCode===code})||fleetByCode.get(code);if(!vehicle)return;var vo=a.allMatched.filter(function(r){return r.vehicleCode===code}).sort(function(x,y){return y.start-x.start}),periodVo=a.orders.filter(function(r){return r.vehicleCode===code}),vehicleItems=[];periodVo.forEach(function(r){vehicleItems=vehicleItems.concat(itemsByOs.get(r.os)||[])});var categories=aggregate(vehicleItems,function(i){return i.category}),categoryCost=aggregate(vehicleItems,function(i){return i.category},function(rows){return sum(rows,'totalValue')}),itemUse=aggregate(vehicleItems,function(i){return i.description},function(rows){return sum(rows,'quantity')}),monthly=aggregate(periodVo,function(r){return r.start.getFullYear()+'-'+String(r.start.getMonth()+1).padStart(2,'0')},function(rows){return sum(rows,'cost')}).sort(function(x,y){return x.label.localeCompare(y.label)}),recurrent=vo.filter(function(r){return a.recurrence.d90.has(r.os)}).length,last=vo[0],openCount=vo.filter(isOpen).length,history=vo.slice(0,50).map(function(r){return'<tr><td><button class="link" type="button" data-open-os="'+esc(r.os)+'">O.S. '+esc(r.os)+'</button></td><td>'+fmtDateTime(r.start)+'</td><td>'+esc(r.status)+'</td><td>'+esc(r.maintenance)+'</td><td class="num">'+fmtCurrency(r.productCost)+'</td><td class="num">'+fmtCurrency(r.serviceCost)+'</td><td class="num">'+fmtCurrency(r.cost)+'</td></tr>'}),kpis='<div class="modal-kpis">'+metric('O.S. no período',fmtNumber(vehicle.orders||0))+metric('Corretivas',fmtNumber(vehicle.corrective||0))+metric('Preventivas',fmtNumber(vehicle.preventive||0))+metric('Custo',fmtCurrency(vehicle.cost||0))+metric('Produtos',fmtCurrency(vehicle.productCost||0))+metric('Serviços',fmtCurrency(vehicle.serviceCost||0))+metric('Parada',fmtHours(vehicle.downtime||0))+metric('Disponibilidade estimada',fmtPercent(vehicle.availability===undefined?100:vehicle.availability))+metric('MTTR estimado',fmtHours(vehicle.mttr||0))+metric('Última O.S.',last?fmtDate(last.start):'--')+metric('O.S. abertas',fmtNumber(openCount))+metric('Reincidências 90d',fmtNumber(recurrent))+'</div>',details='<div class="detail-grid">'+detail('Frota / placa',vehicleName(vehicle))+detail('Tipo',vehicle.type)+detail('Marca / modelo',vehicle.brand+' - '+vehicle.model,'span2')+detail('Ano / idade',(vehicle.year||'--')+' - '+(vehicle.age===null?'--':vehicle.age+' anos'))+detail('CR',centerName(vehicle))+detail('Regional',vehicle.regional)+detail('Gestor',vehicle.manager)+detail('KM atual',fmtNumber(vehicle.kmCurrent))+detail('KM rodado/dia',fmtNumber(vehicle.kmDay))+detail('Próprio / terceiro',vehicle.ownership)+detail('Indicador de atenção',vehicle.attention||'Verde')+'</div>',blocks='<section class="modal-section"><div class="grid-3"><article class="panel"><h3 class="panel-title">Evolução mensal do custo</h3><div class="summary" style="margin-top:8px">'+monthly.map(function(x){return'<div class="summary-item"><span>'+esc(x.label)+'</span><strong>'+fmtCurrency(x.value,true)+'</strong></div>'}).join('')+'</div></article><article class="panel"><h3 class="panel-title">Categorias frequentes</h3><div class="summary" style="margin-top:8px">'+categories.slice(0,6).map(function(x){return'<div class="summary-item"><span>'+esc(x.label)+'</span><strong>'+fmtNumber(x.value)+'</strong></div>'}).join('')+'</div></article><article class="panel"><h3 class="panel-title">Categorias mais caras</h3><div class="summary" style="margin-top:8px">'+categoryCost.slice(0,6).map(function(x){return'<div class="summary-item"><span>'+esc(x.label)+'</span><strong>'+fmtCurrency(x.value,true)+'</strong></div>'}).join('')+'</div></article><article class="panel"><h3 class="panel-title">Itens mais usados</h3><div class="summary" style="margin-top:8px">'+itemUse.slice(0,6).map(function(x){return'<div class="summary-item"><span>'+esc(x.label)+'</span><strong>'+fmtNumber(x.value,2)+'</strong></div>'}).join('')+'</div></article></div></section><section class="modal-section"><div class="panel-head"><div><h3 class="panel-title">Histórico de O.S.</h3><p class="panel-subtitle">Até 50 registros; clique na O.S. para consultar produtos e serviços</p></div></div>'+miniTable(['O.S.','Início','Status','Manutenção','Produtos','Serviços','Total'],history)+'</section>';openModal(vehicleName(vehicle),vehicle.type+' - '+vehicle.brand+' '+vehicle.model,'Visão gerencial do ativo',kpis+details+blocks,{type:'vehicle',value:vehicle.vehicleCode,trigger:trigger})}
    function brandLogo(){var image=document.querySelector('.brand-mark img');return image&&image.getAttribute('src')&&image.style.display!=='none'?image.getAttribute('src'):''}
    function sheetItemTable(title,rows,total){
        if(!rows.length)return'<p class="sheet-empty">Nenhum registro de '+esc(title.toLowerCase())+' vinculado a esta O.S.</p>';
        var ordered=rows.slice().sort(function(a,b){return txt(a.description).localeCompare(txt(b.description),'pt-BR',{numeric:true})}),
            body=ordered.map(function(item){return'<tr><td class="mid">'+esc(item.code)+'</td><td>'+esc(item.description)+'</td><td>'+esc(item.macro)+'</td><td>'+esc(item.sub)+'</td><td>'+esc(valueOrInfo(item.partner))+'</td><td class="num">'+fmtNumber(item.quantity,2)+'</td><td class="num">'+fmtCurrency(item.unitValue)+'</td><td class="num">'+fmtCurrency(item.totalValue)+'</td></tr>'}).join('');
        return'<table class="sheet-table"><colgroup><col style="width:7%"><col style="width:32%"><col style="width:11%"><col style="width:12%"><col style="width:12%"><col style="width:6%"><col style="width:10%"><col style="width:10%"></colgroup>'
            +'<thead><tr><th class="mid">Código</th><th>Descrição</th><th>Categoria</th><th>Sub-categoria</th><th>Parceiro</th><th class="num">Qtd.</th><th class="num">Valor unit.</th><th class="num">Valor total</th></tr></thead>'
            +'<tbody>'+body+'</tbody><tfoot><tr><td colspan="7">Total de '+esc(title.toLowerCase())+'</td><td class="num">'+fmtCurrency(total)+'</td></tr></tfoot></table>';
    }
    function sheetField(label,value,cls){return'<div class="sheet-field '+(cls||'')+'"><span>'+esc(label)+'</span><strong>'+esc(valueOrInfo(value))+'</strong></div>'}
    function buildOrderSheet(row){
        var osItems=itemsByOs.get(row.os)||[],open=isOpen(row),closeDate=open?null:row.closedDate,duration=Math.max(0,((open?new Date():(closeDate||row.endCalc))-row.start)/HOUR),
            issued=new Date(),
            context=[row.fleet?'Frota '+row.fleet:'',centerName(row)].filter(Boolean).join(' · '),
            identification=sheetField('Veículo',vehicleName(row))+sheetField('Placa',row.plate)+sheetField('Frota',row.fleet)+sheetField('Tipo',row.type)
                +sheetField('Marca / modelo',[row.brand,row.model].filter(Boolean).join(' - '),'w6')+sheetField('Ano/modelo',row.year||'')+sheetField('Próprio',row.ownership)
                +sheetField('Centro de resultado',centerName(row),'w6')+sheetField('Regional',row.regional)+sheetField('Gestor',row.manager),
            data=sheetField('Status',row.status)+sheetField('Manutenção',row.maintenance)+sheetField('Tipo da O.S.',row.orderType)
                +sheetField('Início',fmtDateTime(row.start))+sheetField('Encerramento',open?'Em aberto':fmtDateTime(closeDate))+sheetField('Duração',fmtHours(duration))
                +sheetField('KM',row.km===null?'':fmtNumber(row.km))+sheetField('Horímetro',row.hourMeter===null?'':fmtNumber(row.hourMeter)),
            costs=sheetField('Custo de produtos',fmtCurrency(row.productCost))+sheetField('Custo de serviços',fmtCurrency(row.serviceCost))+sheetField('Custo total',fmtCurrency(row.cost),'accent')+sheetField('Itens vinculados',fmtNumber(row.items)),
            products=osItems.filter(function(item){return norm(item.itemType)==='produto'}),
            services=osItems.filter(function(item){return norm(item.itemType)!=='produto'}),
            productBlock=sheetItemTable('Produtos',products,row.productCost),
            serviceBlock=sheetItemTable('Serviços',services,row.serviceCost),
            logo=brandLogo();
        return'<article class="sheet"><header class="sheet-head">'
            +'<div class="sheet-brand">'+(logo?'<div class="sheet-logo"><img src="'+esc(logo)+'" alt="MB Limpeza Urbana"></div>':'')+'<div class="sheet-company"><strong>MB LIMPEZA URBANA</strong><span>Planejamento e Controle da Manutenção</span>'+(context?'<em>'+esc(context)+'</em>':'')+'</div></div>'
            +'<div class="sheet-title"><p class="sheet-kicker">PCM - Análise de Ordens de Serviço</p><h1>Registro de Ordem de Serviço</h1></div>'
            +'<div class="sheet-id"><span>O.S.</span><strong>'+esc(row.os)+'</strong></div></header>'
            +'<section class="sheet-block"><h2>Identificação do ativo</h2><div class="sheet-grid">'+identification+'</div></section>'
            +'<section class="sheet-block"><h2>Dados da O.S.</h2><div class="sheet-grid">'+data+'</div></section>'
            +'<section class="sheet-block"><h2>Custos</h2><div class="sheet-grid">'+costs+'</div></section>'
            +'<section class="sheet-block"><h2>Observação</h2><div class="sheet-grid">'+sheetField('Observação registrada',row.observation,'full')+'</div></section>'
            +'<section class="sheet-block table-block"><h2>Produtos</h2>'+productBlock+'</section>'
            +'<section class="sheet-block table-block"><h2>Serviços</h2>'+serviceBlock+'</section>'
            +'<footer class="sheet-foot"><div class="sheet-stamp">'+esc(fmtDateTime(issued))+'</div>'
            +'<div class="sheet-doc"><p>Emitido em '+esc(issued.toLocaleString('pt-BR'))+' pelo painel PCM - Análise de Ordens de Serviço.</p><p>Documento gerado a partir dos dados da O.S. no Sankhya; não substitui o registro oficial do sistema.</p></div>'
            +'<div class="sheet-tag">O.S. '+esc(row.os)+'</div></footer></article>';
    }
    function sheetStyles(){var node=id('sheetStyle');return node?node.textContent:''}
    function viewerStyles(){
        return'@page{size:A4 portrait;margin:6mm}*{box-sizing:border-box}html,body{margin:0;background:#e9eef3;font-family:Inter,"Segoe UI",Arial,Helvetica,sans-serif}'
            +'.viewer-bar{position:sticky;z-index:5;top:0;display:flex;align-items:center;justify-content:space-between;gap:16px;padding:10px 16px;color:#fff;background:#0B3A6E}'
            +'.viewer-bar strong{display:block;font-size:12px;font-weight:800}'
            +'.viewer-bar span{display:block;margin-top:2px;color:#c9dcef;font-size:10px}'
            +'.viewer-bar button{padding:9px 15px;border:0;border-radius:8px;color:#0B3A6E;background:#fff;font-size:11px;font-weight:800;cursor:pointer}'
            +'.viewer-page{width:210mm;max-width:100%;min-height:297mm;margin:16px auto;padding:8mm;background:#fff;box-shadow:0 10px 30px rgba(11,31,51,.18)}'
            +'@media print{html,body{background:#fff}.viewer-bar{display:none}.viewer-page{width:auto;min-height:0;margin:0;padding:0;box-shadow:none}*{-webkit-print-color-adjust:exact!important;print-color-adjust:exact!important}}';
    }
    function orderSheetDocument(row){
        return'<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
            +'<title>Registro_OS_'+esc(row.os)+'</title><style>'+viewerStyles()+sheetStyles()+'</style></head><body>'
            +'<div class="viewer-bar"><div><strong>Registro de Ordem de Serviço · O.S. '+esc(row.os)+'</strong>'
            +'<span>Confira a ficha e use o botão ao lado para salvar em PDF. No diálogo de impressão, desmarque "Cabeçalhos e rodapés" para tirar a URL e a data do navegador.</span></div>'
            +'<button type="button" onclick="window.print()">Salvar em PDF</button></div>'
            +'<div class="viewer-page">'+buildOrderSheet(row)+'</div></body></html>';
    }
    function historySheetDocument(rows){
        var sheets=rows.map(function(row){return'<div class="viewer-page viewer-batch-page">'+buildOrderSheet(row.source)+'</div>'}).join('');
        return'<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
            +'<title>Historico_OS_'+esc(dateInput(new Date()))+'</title><style>'+viewerStyles()+sheetStyles()
            +'.viewer-batch-page{break-after:page;page-break-after:always}.viewer-batch-page:last-child{break-after:auto;page-break-after:auto}</style></head><body>'
            +'<div class="viewer-bar"><div><strong>Histórico de Ordens de Serviço - '+esc(fmtNumber(rows.length))+' O.S.</strong>'
            +'<span>As fichas seguem os filtros e a ordenação da tabela. Use o botão ao lado para salvar o documento em PDF.</span></div>'
            +'<button type="button" onclick="window.print()">Salvar em PDF</button></div>'+sheets+'</body></html>';
    }
    function printOrderSheet(){
        var record=state.modalRecord,row=record&&record.type==='os'?orderById.get(record.value):null;
        if(!row)return;
        var view=window.open('','_blank');
        if(!view){window.alert('Permita a abertura de pop-ups para visualizar a ficha da O.S.');return}
        try{
            view.document.open();
            view.document.write(orderSheetDocument(row));
            view.document.close();
            view.focus();
        }catch(error){
            window.alert('Não foi possível abrir a ficha em nova aba.');
            try{view.close()}catch(ignore){}
        }
    }
    function printHistorySheets(){
        var rows=state.historySorted||[];
        if(!rows.length){window.alert('Não há O.S. para exportar com os filtros atuais.');return}
        var view=window.open('','_blank');
        if(!view){window.alert('Permita a abertura de pop-ups para visualizar o PDF das O.S. filtradas.');return}
        try{
            view.document.open();
            view.document.write(historySheetDocument(rows));
            view.document.close();
            view.focus();
        }catch(error){
            window.alert('Não foi possível abrir o PDF das O.S. filtradas em nova aba.');
            try{view.close()}catch(ignore){}
        }
    }
    function openModal(title,subtitle,kicker,body,record){setText('modalTitle',title);setText('modalSubtitle',subtitle);setText('modalKicker',kicker);id('modalBody').innerHTML=body;state.modalRecord=record||null;state.returnFocus=record&&record.trigger?record.trigger:document.activeElement;id('modalPrimary').hidden=!(record&&record.type==='os');id('modalPdf').hidden=!(record&&record.type==='os');id('modalSecondary').hidden=!(record&&record.type==='vehicle');id('mainModal').hidden=false;document.body.classList.add('modal-open');setTimeout(function(){id('modalClose').focus()},0)}
    function closeModal(){if(id('mainModal').hidden)return;id('mainModal').hidden=true;document.body.classList.remove('modal-open');state.modalRecord=null;var target=state.returnFocus;state.returnFocus=null;if(target&&target.focus)target.focus()}
    function getOpenApp(){if(typeof window.openApp==='function')return window.openApp.bind(window);try{if(window.parent&&typeof window.parent.openApp==='function')return window.parent.openApp.bind(window.parent)}catch(ignore){}return null}
    function openRecord(app,key,value){var fn=getOpenApp();if(!fn){window.alert('Não foi possível acessar a navegação do Sankhya.');return}var params={},numeric=Number(value);params[key]=Number.isFinite(numeric)?numeric:value;try{fn(app,params)}catch(error){window.alert('Não foi possível abrir o registro selecionado.')}}
    function csvCell(value){return'"'+txt(value).replace(/"/g,'""')+'"'}
    function exportBacklog(){var a=state.analysis,headers=['Prioridade','Score','O.S.','Veículo','Placa','Frota','Tipo','CR','Regional','Gestor','Status','Manutenção','Abertura','Dias aberta','Última alteração','Dias sem alteração','Custo','Itens','Observação','KM','Plano'],lines=[headers.map(csvCell).join(';')];a.open.forEach(function(r){lines.push([r.priorityLabel,r.priority,r.os,r.vehicleCode,r.plate,r.fleet,r.type,centerName(r),r.regional,r.manager,r.status,r.maintenance,fmtDateTime(r.openDate||r.start),r.age,fmtDateTime(r.changeDate),r.stale,r.cost.toFixed(2).replace('.',','),r.items,r.observation,r.km===null?'':r.km,r.plan].map(csvCell).join(';'))});var blob=new Blob(['\ufeff'+lines.join('\r\n')],{type:'text/csv;charset=utf-8;'}),link=document.createElement('a');link.href=URL.createObjectURL(blob);link.download='backlog_pcm_'+dateInput(new Date())+'.csv';document.body.appendChild(link);link.click();link.remove();URL.revokeObjectURL(link.href)}
    function render(){var a=buildAnalysis();state.analysis=a;setText('periodText','Período: '+fmtDate(a.period.start)+' a '+fmtDate(new Date(a.period.end.getTime()-DAY)));setText('sourceText','Carga: '+fmtNumber(orders.length)+' O.S. - '+fmtNumber(items.length)+' itens - janela '+fmtDate(loadWindow.start)+' a '+fmtDate(loadWindow.end));id('sourceText').title='Janela buscada no banco: '+fmtDate(loadWindow.start)+' a '+fmtDate(loadWindow.end)+'. Todas as O.S. em aberto vêm sempre, independentemente da janela.';updateLoadState(a.period);setText('resultOrders',fmtNumber(a.orders.length));setText('resultFleet',fmtNumber(a.fleet.length));renderExecutive(a);renderPCM(a);renderReliability(a);renderCosts(a);renderFleet(a);renderHistory(a)}

    resetPeriod();restorePeriodFromUrl();initFilters();initColumns();initHistoryColumns();setText('updatedAt',new Date().toLocaleString('pt-BR',{day:'2-digit',month:'2-digit',year:'numeric',hour:'2-digit',minute:'2-digit'}));
    var searchTimer=null;id('searchInput').addEventListener('input',function(){window.clearTimeout(searchTimer);searchTimer=window.setTimeout(render,120)});id('dateStart').addEventListener('change',render);id('dateEnd').addEventListener('change',render);
    id('applyPeriod').addEventListener('click',applyLoadPeriod);id('clearFilters').addEventListener('click',function(){id('searchInput').value='';Object.keys(filterDefs).forEach(function(key){filterDefs[key].selected.clear();renderFilter(key)});resetPeriod();render()});
    Array.prototype.forEach.call(document.querySelectorAll('.tab'),function(tab){tab.addEventListener('click',function(){Array.prototype.forEach.call(document.querySelectorAll('.tab'),function(other){var active=other===tab;other.classList.toggle('active',active);other.setAttribute('aria-selected',active?'true':'false');id(other.dataset.page).hidden=!active})})});
    id('backlogTable').addEventListener('click',function(event){var header=event.target.closest('[data-sort]');if(!header)return;var key=header.dataset.sort;if(state.backlogSort.key===key)state.backlogSort.dir=state.backlogSort.dir==='asc'?'desc':'asc';else{state.backlogSort.key=key;state.backlogSort.dir=key==='os'||key==='fleet'?'asc':'desc'}renderPCM(state.analysis)});
    id('historyTable').addEventListener('click',function(event){var header=event.target.closest('[data-sort]');if(!header)return;var key=header.dataset.sort,column=historyColumn(key);if(!column)return;if(state.historySort.key===key)state.historySort.dir=state.historySort.dir==='asc'?'desc':'asc';else{state.historySort.key=key;state.historySort.dir=column.type==='string'?'asc':'desc'}renderHistory(null,true)});
    id('historyMore').addEventListener('click',function(){state.historyLimit+=HISTORY_PAGE;renderHistory(null,true)});
    id('exportHistoryXlsx').addEventListener('click',exportHistoryXlsx);id('exportHistoryCsv').addEventListener('click',exportHistoryCsv);id('exportHistoryPdf').addEventListener('click',printHistorySheets);
    document.addEventListener('click',function(event){var osButton=event.target.closest('[data-open-os]'),vehicleButton=event.target.closest('[data-open-vehicle]');if(osButton){openOrder(orderById.get(osButton.dataset.openOs),osButton);return}if(vehicleButton)openVehicle(vehicleButton.dataset.openVehicle,vehicleButton)});
    id('qualityButton').addEventListener('click',function(){renderQuality(state.analysis)});id('exportBacklog').addEventListener('click',exportBacklog);id('modalPdf').addEventListener('click',printOrderSheet);id('modalClose').addEventListener('click',closeModal);id('modalFooterClose').addEventListener('click',closeModal);id('mainModal').addEventListener('click',function(event){if(event.target===id('mainModal'))closeModal()});id('modalPrimary').addEventListener('click',function(){if(state.modalRecord&&state.modalRecord.type==='os')openRecord(OS_APP,'NUOS',state.modalRecord.value)});id('modalSecondary').addEventListener('click',function(){if(state.modalRecord&&state.modalRecord.type==='vehicle')openRecord(VEHICLE_APP,'CODVEICULO',state.modalRecord.value)});document.addEventListener('keydown',function(event){if(event.key==='Escape'){closeMenus(null);id('columnMenu').hidden=true;if(!id('mainModal').hidden)closeModal()}});
    render();
})();
</script>
</body>
</html>
