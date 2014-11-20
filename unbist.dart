import 'dart:html';
import 'package:xml/xml.dart';

final uri_scheme = "http";
final base_uri = "unbis-thesaurus.s3-website-us-east-1.amazonaws.com";
final uri_data_path = "xml";
final default_locale = "en";
final description_doc = "01";

var specificLabel = '';

void main() {
  // things to do: 
  // Get locale (default is en)
  // Determine what is in the query string and display that
  // Get labels in locale for each relationship
  // Build available formats list from term id
  
  var descriptionContainer = querySelector('#descriptionContainer');
  var termContainer = querySelector('#termContainer');
  var requestedUri = Uri.parse(window.location.toString());
  var locale = default_locale;
  var termDoc = new Uri(scheme: uri_scheme, 
       host: base_uri, 
       path: '/${uri_data_path}/${description_doc}.${uri_data_path}');
  
  if(requestedUri.query.length > 0) {
    if(requestedUri.queryParameters['locale'] != null) {
      locale = requestedUri.queryParameters['locale'];
      if(locale.toLowerCase() == "ar") {
        termContainer.dir = "rtl";
      }
    }
    if(requestedUri.queryParameters['t'] != null) {
      var termId = requestedUri.queryParameters['t'];
      termDoc = new Uri(scheme: uri_scheme, 
          host: base_uri, 
          path: '/${uri_data_path}/${termId}.${uri_data_path}');
    }
  } 
  print(termDoc);
  getTerm(termDoc,locale);
}

void getTerm(uri,locale) {
  //var uri = new Uri(scheme: uri_scheme, host: base_uri, path: uri_data_path + termDoc );
  //var uri = Uri.parse(termDoc);
  var request = new HttpRequest();
  request.open('GET', uri.toString());
  request.onLoad.listen((event) {
    //print(event.target.status);
    if (event.target.status == 200) {
        var data = parse(event.target.responseText);
        buildTermPage(data,locale);        
    } else {
      // request an error page...
    }
  });
  request.send();
}

void buildTermPage(data,locale) {
  // Things a "term" might have:
  // Preferred labels (required)
  // Alternate labels (optional)
  // Members (required only for categories)
  // Top Concepts (required only for concept scheme)
  // Broader terms (optional, only for concepts)
  // Related terms (optional, only for concepts)
  // Narrower terms (optional, only for concepts)
  // Scope notes (optional, only for concepts)
  var descriptionContainer = querySelector('#descriptionContainer');
  var termContainer = querySelector('#termContainer');
  //termContainer.appendText(data.toString());
  var prefLabels = data.findAllElements('skos:prefLabel');
  if(prefLabels != null) {
    termContainer.appendHtml('<ul id="prefLabel">');
    for (var label in prefLabels) {
      //print('xml:lang="${locale}"');
      if(label.attributes.first.toString() == 'xml:lang="${locale}"') {
        descriptionContainer.appendHtml('<h1>' + label.text + '</h1>');
      }
      querySelector('#prefLabel').appendHtml('<li>skos:prefLabel ' + label.text + ' @' + label.attributes.first.toString() + '</li>');
    }
    termContainer.appendHtml('</ul>');
  }
  var altLabels = data.findAllElements('skos:altLabel');
  if(altLabels != null) {
    termContainer.appendHtml('<ul id="altLabel">');
    for (var label in altLabels) {
      querySelector('#altLabel').appendHtml('<li>skos:altLabel ' + label.text + ' @' + label.attributes.first.toString() + '</li>');
    }
    termContainer.appendHtml('</ul>');
  }
  var members = data.findAllElements('skos:member');
  if(members != null) {
    termContainer.appendHtml('<ul id="member">');
    for(var member in members) {
      var termUri = member.attributes.first.toString().split('?')[1].replaceAll(new RegExp(r'"'), '').replaceAll(new RegExp(r't='), '');
      getTermLabel(termUri,locale,'member');
    }
    termContainer.appendHtml('</ul>');
  }
  var topConcepts = data.findAllElements('skos:hasTopConcept');
  if(topConcepts != null) {
    termContainer.appendHtml('<ul id="hasTopConcept">');
    for(var topConcept in topConcepts) {
      var termUri = topConcept.attributes.first.toString().split('?')[1].replaceAll(new RegExp(r'"'), '').replaceAll(new RegExp(r't='), '');
      getTermLabel(termUri,locale,'hasTopConcept');
    }
    termContainer.appendHtml('</ul>');
  }
  var broader = data.findAllElements('skos:broader');
  if(broader != null) {
    termContainer.appendHtml('<ul id="broader">');
    for(var b in broader) {
      //print(b.attributes.first.toString().split('?')[1].replaceAll(new RegExp(r'"'), ''));
      var termUri = b.attributes.first.toString().split('?')[1].replaceAll(new RegExp(r'"'), '').replaceAll(new RegExp(r't='), '');
      getTermLabel(termUri,locale,'broader');
    }
    termContainer.appendHtml('</ul>');
  }
  var related = data.findAllElements('skos:related');
  if(related != null) {
    termContainer.appendHtml('<ul id="related">');
    for(var r in related) {
      var termUri = r.attributes.first.toString().split('?')[1].replaceAll(new RegExp(r'"'), '').replaceAll(new RegExp(r't='), '');
      getTermLabel(termUri,locale,'related');
    }
    termContainer.appendHtml('</ul>');
  }
  var narrower = data.findAllElements('skos:narrower');
  if(narrower != null) {
    termContainer.appendHtml('<ul id="narrower">');
    for(var n in narrower) {
      var termUri = n.attributes.first.toString().split('?')[1].replaceAll(new RegExp(r'"'), '').replaceAll(new RegExp(r't='), '');
      getTermLabel(termUri,locale,'narrower');
    }
    termContainer.appendHtml('</ul>');
  }
  var scopeNotes = data.findAllElements('skos:scopeNote');
  if(scopeNotes != null) {
    termContainer.appendHtml('<ul id="scopeNote">');
    for(var scopeNote in scopeNotes) {
      querySelector('#scopeNote').appendHtml('<li>skos:scopeNote ' + scopeNote.text + '</li>');
    }
    termContainer.appendHtml('</ul>');
  }
}

void getTermLabel(uri,locale,context) {
  //var termUri = Uri.parse(uri);
  //var actualUri = termUri.replace(path: '/xml/' + termUri.path + '.xml');
  //print('Getting ${locale} label from ${actualUri}');
  var actualUri = 'http://${base_uri}/xml/${uri}.xml';
  var request = new HttpRequest();
  request.open('GET', actualUri.toString());
  request.onLoad.listen((event) {
    //print(event.target.status);
    if (event.target.status == 200) {
        var data = parse(event.target.responseText);
        var prefLabels = data.findAllElements('skos:prefLabel');
        if(prefLabels != null) {
          for (var label in prefLabels) {
            if(label.attributes.first.toString() == 'xml:lang="${locale}"') {
              var targetUri = '?t=${uri}&locale=${locale}';
              querySelector('#${context}').appendHtml('<li>skos:${context} <a href=${targetUri}>' + label.text + '</a></li>');
            }
          }
        }
    } else {
      // request an error page...
    }
  });
  request.send();
  return;
}