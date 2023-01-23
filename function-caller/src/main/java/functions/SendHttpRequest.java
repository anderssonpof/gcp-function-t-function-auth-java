package functions;

import com.google.api.client.http.HttpResponse;
import com.google.cloud.functions.HttpFunction;
import com.google.cloud.functions.HttpRequest;
import java.util.logging.Logger;

public class SendHttpRequest implements HttpFunction {
  private static final Logger logger = Logger.getLogger(SendHttpRequest.class.getName());

  @Override
  public void service(HttpRequest request, com.google.cloud.functions.HttpResponse response) throws Exception {
    String url =  System.getenv("FUNCTION_URL");
    HttpResponse GetResponse = Authentication.makeGetRequest(url, url);
    logger.info("Response: "+GetResponse.parseAsString() );
  }
}
