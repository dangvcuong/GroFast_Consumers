import 'package:googleapis_auth/auth_io.dart';

class GetServiceKey{
  // Future<String> getServiceKeyToken() async {
  //   final scopes = [
  //     'https://www.googleapis.com/auth/userinfo.email',
  //     'https://www.googleapis.com/auth/firebase.database',
  //     'https://www.googleapis.com/auth/firebase.messaging',
  //   ];
  //
  //
  //   final client = await clientViaServiceAccount(
  //       ServiceAccountCredentials.fromJson(
  //         {
  //           "type": "service_account",
  //           "project_id": "profast-e9fdf",
  //           "private_key_id": "7b896cbf9fe0c3823c17a4d389baac720807298f",
  //           "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDB7LuXm/n5J1U29gb5F/tuTbHZOvSLD2AhN6Xzl5/yHUmm9kF/x491UHsRbj/0ck5O4FkyT05D5FWg\ns2DfytrUL+euFLmxEAmLCxL5csBA0vWWSQJa2dEeDh49lGvpzB5o5vEG16JMR3jZ\n+YocPiK0/oRfHH6yXA7x8TFITYx7hmSXoqTm0Ikv2XEHMmv+t4RkTERzakMc+lGF\n/uaPs/+U7mfJ8jT7qT+UqG3mEvmfkOEAD8EXENacjujW+faaMbFHoNgDqR79tP3R\n3oL71XZi1pjzORr+wtVetW4HQh48kqqPCwm++scSIpD3mNhHh7O/PWLsQHL6T1ol\ncpmw0NYPAgMBAAECggEAPK1v/P4m9xihhzLv95zTZS4WSdwyjBhhgcNBv7hfqYgU\ndZNz5yFv98sY1tliVYA2lGOKRT2fRYr6Z+/4jc2RLvdWTJfbilV0RvdOFpMbKK1Z\nfo6VmAuzbO4J9EauhVcC5Nvt6rAp7igm3j1AQ5oFjhBdJs1przEy0+0d+HubS0Kz\nGHK5CsgeWc7DUs3A14Zso7gUsnNT/kzJFf6nObvKk2IEvft0emRjGcEjvO2ElF0R\nrNBu+ezkOk81Nybvsssfm64aBi9MQU+4FDVMNbeiCVdwYx9H+Gr2x5pBeh0p4nzn\n7qLAPm5haSJb7/207SBjXcpY9n0cPO3ijOerVvlPUQKBgQD/UEkvekRCu+BClGFp\nyh5vs37sbRvE74UQAZx5Dsp23G7Ty6cGA8eOBiXNim8VFHo10YATDxSI2ekfo2R8\ni0T9ncRTlVCakuHDsAzYoKiYibFmiZGP2L6d8P2QDVPx7lepPR8I0ikPmeOksOjH\nS//MnfMzydwwr+0j/oPy0AHLZQKBgQDCcjKDtkox57ACnAz2QTDvnGTfC+yWLT+h\ntdMxv+UCzRCXqeX7L5mdzhOZRCEdbC6jRLTvZMtdLP6hDEgqEDAPr8hSV075T69U\njKqI75a8Oo2eJNiRUcY0jNc9IDlHGdZNgQdO1h1/WNaqut6lTw7zQyzjC6UEhLun\njFnJrQqWYwKBgQCqagxvhEzLvluSFThwRFjMdiLh7HH8oWNPq8OlihnZ/Ih9FhIG\nEb/BLJlO+Hfsuh5Yjd3O2uH59nmEhKst9ke2gPfqUl/azO+kjn4EmjfumPmwV2Kx\ngRq6kYCuBjdh5JTegc2VNbHyl+U6qFq3rCKxkTwj9Tjjxomi3N910yFfgQKBgQCQ\nEGP0yh52kx4JEO1ZljtXjBwAValYKvY2Lazn8zENvjlI5QwL6tx52rESoTOXxQtY\n1BLqO1ehFTEiySK+Z3f0Z1yYBS/x72QL1JyVEE4x73/1Z389S8T6Mk9WboWBdFce\n3TY45tK8A2oo3IMRH14IRgD/xyTgECeon4f2sEpj2QKBgQCwX3QQdwsiQG//7dDS\nLBmXfWN8mI7rU3WVbMsnJiDv6bli1AdBBssfRVf7nNRs/czLc+MGaUfPNtOP8s9v\nXGQxkJAIJtl9edIgI6Bx/MIHcBFiAnpo+VmkF4qmr5ZNgxWWE2fq9rqq0a0XHvjk\nW0HDWAUcT83U/Y/YFCKbpQMgqw==\n-----END PRIVATE KEY-----\n",
  //           "client_email": "firebase-adminsdk-xuwtj@profast-e9fdf.iam.gserviceaccount.com",
  //           "client_id": "105552527742807998090",
  //           "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  //           "token_uri": "https://oauth2.googleapis.com/token",
  //           "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  //           "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xuwtj%40profast-e9fdf.iam.gserviceaccount.com",
  //           "universe_domain": "googleapis.com"
  //         },
  //   ),
  //       scopes,
  //   );
  //   final acccesServerKey = client.credentials.accessToken.data;
  //   return acccesServerKey;
  // }
}